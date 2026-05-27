import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "./models/cluster/model.tsp";
import "./models/cluster/example_cluster.tsp";
import "./models/cluster/example_post.tsp";
import "./models/cluster/example_patch.tsp";
import "./models/nodepool/model.tsp";
import "./models/nodepool/example_nodepool.tsp";
import "./models/nodepool/example_post.tsp";
import "./models/nodepool/example_patch.tsp";
import "./models/channel/model.tsp";
import "./models/version/model.tsp";

import "hyperfleet/shared/services/clusters.tsp";
import "hyperfleet/shared/services/nodepools.tsp";
import "./services/channels.tsp";
import "./services/versions.tsp";

using Http;
using OpenAPI;

/**
 * HyperFleet API provides simple CRUD operations for managing cluster resources and their status history.
 *
 * **Architecture**: Simple CRUD only, no business logic, no event creation.
 * Sentinel operator handles all orchestration logic.
 * Adapters handle the specifics of managing spec
 *
 */
@service(#{ title: "HyperFleet API" })
@info(#{
  version: "1.0.19",
  contact: #{
    name: "HyperFleet Team",
    url: "https://github.com/openshift-hyperfleet",
  },
  license: #{
    name: "Apache 2.0",
    url: "https://www.apache.org/licenses/LICENSE-2.0",
  },
})
@server("https://hyperfleet.redhat.com", "Production")
@route("/api/hyperfleet/v1")
namespace HyperFleet;

// Override BearerAuth to use lowercase "bearer" as required by kin-openapi
model BearerAuth {
  type: AuthType.http;
  scheme: "bearer";
}
