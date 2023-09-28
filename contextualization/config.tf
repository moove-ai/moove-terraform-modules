locals {
    swagger_config = <<EOT
    swagger: '2.0'
    info:
      description: 
      version: '0.1'
      title: 
    x-google-backend:
      address: 
    securityDefinitions:
      api_key:
        type: apiKey
        name: key
        in: query
    paths:
      /api/v1/contextualize:
        post:
          operationId: contextualize
          security:
          - api_key: []
          consumes:
            - application/json
          produces:
            - application/json
          parameters:
            - in: body
              name: body
              required: false
              schema:
                $ref: '#/definitions/Model0'
              x-examples:
                application/json: |-
                  {
                    "time_field": "capturedTimestamp",
                    "long_field": "longitude",
                    "lat_field": "latitude",
                    "heading_field": "heading",
                    "datasets": [
                      "join_to_road",
                      "static",
                      "periodic",
                      "dynamic",
                      "raw_weather",
                      "discrete"
                    ],
                    "lines": [
                      {
                        "dataPointId": "-3327917072834082339",
                        "journeyId": "-1643571555871430424",
                        "capturedTimestamp": "2023-05-20T15:41:02.000-0400",
                        "latitude": 41.827525,
                        "longitude": -71.398007,
                        "lat_lon_partition": "1129",
                        "speed": 34.55,
                        "heading": 90,
                        "squishVin": "1GKKNRL4LZ",
                        "ignitionStatus": "MID_JOURNEY"
                      }
                    ]
                  }
          responses:
            '200':
              description: Definition generated from Swagger Inspector
              schema:
                $ref: '#/definitions/Model1'
    definitions:
      Lines:
        properties:
          dataPointId:
            type: string
          journeyId:
            type: string
          capturedTimestamp:
            type: string
          latitude:
            type: number
            format: double
          longitude:
            type: number
            format: double
          lat_lon_partition:
            type: string
          speed:
            type: number
            format: double
          heading:
            type: integer
            format: int32
          squishVin:
            type: string
          ignitionStatus:
            type: string
      Model0:
        properties:
          time_field:
            type: string
          long_field:
            type: string
          lat_field:
            type: string
          heading_field:
            type: string
          datasets:
            type: array
            items:
              type: string
          lines:
            type: array
            items:
              $ref: '#/definitions/Lines'
      Contextualized_data:
        properties:
          dataPointId:
            type: string
          journeyId:
            type: string
          capturedTimestamp:
            type: string
          latitude:
            type: number
            format: double
          longitude:
            type: number
            format: double
          lat_lon_partition:
            type: string
          speed:
            type: number
            format: double
          heading:
            type: integer
            format: int32
          squishVin:
            type: string
          ignitionStatus:
            type: string
          here_segment_id:
            type: string
          functional_class:
            type: string
          snapped_point_lat:
            type: number
            format: double
          snapped_point_lon:
            type: number
            format: double
          distance_from_here_subsegment:
            type: number
            format: double
          segment_timezone:
            type: string
          country_code:
            type: string
          bridge:
            type: boolean
          paved:
            type: boolean
          private:
            type: boolean
          tunnel:
            type: boolean
          movable_bridge:
            type: boolean
          roundabout:
            type: boolean
          curvature:
            type: string
          railway_crossing:
            type: string
          length:
            type: number
            format: double
          slope:
            type: number
            format: double
          max_slope:
            type: integer
            format: int32
          slopes_bumpiness:
            type: number
            format: double
          public_access:
            type: boolean
          limited_access:
            type: boolean
          gate_condition:
            type: string
          special_speed_situation:
            type: string
          carpool_road:
            type: boolean
          ramp:
            type: boolean
          urban:
            type: boolean
          reversible:
            type: boolean
          express_lane:
            type: boolean
          road_divider:
            type: string
          frontage:
            type: boolean
          parkinglot_road:
            type: boolean
          speed_category:
            type: string
          special_speed_situation_type:
            type: string
          four_wheel_drive:
            type: boolean
          poi_access:
            type: boolean
          lane_category:
            type: string
          physical_lane_count:
            type: string
          through_lane_count:
            type: string
          controlled_access:
            type: boolean
          tollway:
            type: boolean
          shape_geom:
            type: string
          centroid:
            type: string
          street_name:
            type: string
          street_language:
            type: string
          min_roughness:
            type: integer
            format: int32
          avg_roughness:
            type: number
            format: double
          max_roughness:
            type: integer
            format: int32
          static_score:
            type: number
            format: double
          curvature_score:
            type: integer
            format: int32
          hard_brake_score:
            type: integer
            format: int32
          road_signs_score:
            type: integer
            format: int32
          paved_score:
            type: integer
            format: int32
          road_roughness_score:
            type: number
            format: double
          ramp_score:
            type: integer
            format: int32
          slope_score:
            type: integer
            format: int32
          traffic_signs_count_score:
            type: integer
            format: int32
          railway_crossing_score:
            type: integer
            format: int32
          urban_score:
            type: integer
            format: int32
          dataPointId_uniq_count:
            type: string
          journeyId_uniq_count:
            type: string
          free_flow_speed:
            type: number
            format: double
          speed_AVG:
            type: number
            format: double
          speed_MIN:
            type: number
            format: double
          speed_MAX:
            type: number
            format: double
          speed_COUNT:
            type: string
          speed_STDDEV:
            type: number
            format: double
          speed_05:
            type: number
            format: double
          speed_25:
            type: number
            format: double
          speed_50:
            type: number
            format: double
          speed_75:
            type: number
            format: double
          speed_85:
            type: number
            format: double
          speed_95:
            type: number
            format: double
          hour_of_day:
            type: string
          day_of_week:
            type: string
          hour_of_week:
            type: string
          hour_of_week_dataPointId_uniq_count:
            type: string
          hour_of_week_journeyId_uniq_count:
            type: string
          hour_of_week_speed_AVG:
            type: number
            format: double
          hour_of_week_speed_MIN:
            type: number
            format: double
          hour_of_week_speed_MAX:
            type: number
            format: double
          hour_of_week_speed_STDDEV:
            type: number
            format: double
          hour_of_week_speed_05:
            type: number
            format: double
          hour_of_week_speed_25:
            type: number
            format: double
          hour_of_week_speed_50:
            type: number
            format: double
          hour_of_week_speed_75:
            type: number
            format: double
          hour_of_week_speed_85:
            type: number
            format: double
          hour_of_week_speed_95:
            type: number
            format: double
          visibility:
            type: integer
            format: int32
          wind_gust:
            type: number
            format: double
          ice_prob:
            type: number
            format: double
          wind_dir:
            type: integer
            format: int32
          snow_prob:
            type: number
            format: double
          wet_prob:
            type: number
            format: double
          precip_sq:
            type: number
            format: double
          dry_prob:
            type: number
            format: double
          risk_blowing_snow:
            type: number
            format: double
          wind_speed:
            type: number
            format: double
          risk_fog:
            type: number
            format: double
          friction:
            type: number
            format: double
          road_cond_severity:
            type: string
          risk_roll_over:
            type: number
            format: double
          precip_probability:
            type: integer
            format: int32
          temperature:
            type: number
            format: double
          dew_point_temperature:
            type: number
            format: double
          snow_rate:
            type: number
            format: double
          road_cond:
            type: string
          snow_thickness:
            type: number
            format: double
          risk_aqua_plane:
            type: number
            format: double
          relative_humidity:
            type: integer
            format: int32
          rain_rate:
            type: number
            format: double
          ice_thickness:
            type: number
            format: double
          altitude:
            type: integer
            format: int32
          water_film_thickness:
            type: number
            format: double
          road_temp:
            type: number
            format: double
          uniq:
            type: integer
            format: int64
          visibility_score:
            type: number
            format: double
          aqua_plane_score:
            type: number
            format: double
          snow_score:
            type: integer
            format: int32
          wind_score:
            type: integer
            format: int32
          rain_score:
            type: integer
            format: int32
          road_iq_score:
            type: number
            format: double
          special_speed_situation_speed_mph:
            type: object
          diminished_priority:
            type: object
          speed_limit_mph:
            type: object
          orientation:
            type: object
          speed_score:
            type: object
      Model1:
        properties:
          invalid_lines:
            type: object
          contextualized_data:
            type: array
            items:
              $ref: '#/definitions/Contextualized_data'
    
EOT
}