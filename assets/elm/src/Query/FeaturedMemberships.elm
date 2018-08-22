module Query.FeaturedMemberships exposing (Response, request)

import Data.GroupMembership exposing (GroupMembership)
import Data.SpaceUser
import GraphQL exposing (Document)
import Json.Decode as Decode
import Json.Encode as Encode
import Session exposing (Session)
import Task exposing (Task)


type alias Response =
    List GroupMembership


document : Document
document =
    GraphQL.toDocument
        """
        query GetFeaturedMemberships(
          $groupId: ID!
        ) {
          group(id: $groupId) {
            featuredMemberships {
              spaceUser {
                ...SpaceUserFields
              }
            }
          }
        }
        """
        [ Data.SpaceUser.fragment
        ]


variables : String -> Maybe Encode.Value
variables groupId =
    Just <|
        Encode.object
            [ ( "groupId", Encode.string groupId )
            ]


decoder : Decode.Decoder Response
decoder =
    Decode.at [ "data", "group", "featuredMemberships" ]
        (Decode.list Data.GroupMembership.decoder)


request : String -> Session -> Task Session.Error ( Session, Response )
request groupId session =
    Session.request session <|
        GraphQL.request document (variables groupId) decoder
