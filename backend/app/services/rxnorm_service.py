"""
PillPal-AI — RxNorm Drug Lookup Service
Uses the public NLM RxNorm REST API to search for drug names.
Docs: https://lhncbc.nlm.nih.gov/RxNav/APIs/RxNormAPIs.html
"""

import httpx

RXNORM_BASE_URL = "https://rxnav.nlm.nih.gov/REST"


async def search_drug(name: str) -> dict:
    """
    Search for a drug by name using the RxNorm API.
    Returns matching concepts or an error message.
    """
    url = f"{RXNORM_BASE_URL}/drugs.json"
    params = {"name": name}

    try:
        async with httpx.AsyncClient(timeout=15.0) as client:
            response = await client.get(url, params=params)
            response.raise_for_status()
            data = response.json()

        # Parse the drugGroup → conceptGroup → conceptProperties
        drug_group = data.get("drugGroup", {})
        concept_groups = drug_group.get("conceptGroup", [])

        results = []
        for group in concept_groups:
            props = group.get("conceptProperties", [])
            for prop in props:
                results.append(
                    {
                        "rxcui": prop.get("rxcui"),
                        "name": prop.get("name"),
                        "synonym": prop.get("synonym", ""),
                        "tty": prop.get("tty"),  # Term Type
                    }
                )

        return {
            "status": "ok",
            "query": name,
            "total_results": len(results),
            "results": results[:10],  # Limit to 10 results
        }

    except httpx.HTTPStatusError as e:
        return {
            "status": "error",
            "message": f"RxNorm API HTTP error: {e.response.status_code}",
        }
    except httpx.RequestError as e:
        return {
            "status": "error",
            "message": f"Gagal terhubung ke RxNorm API: {str(e)}",
        }


async def test_connection() -> dict:
    """
    Ping the RxNorm API with a known drug (aspirin) to verify connectivity.
    """
    return await search_drug("aspirin")
