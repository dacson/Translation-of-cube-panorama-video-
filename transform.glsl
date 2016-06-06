#extension GL_OES_EGL_image_external : require

#define RIGHT   0
#define LEFT    1
#define TOP     2
#define BOTTOM  3
#define FRONT   4
#define BACK    5

#define PI    3.1415926535897932384626433832795

#define  P0  vec3 (-0.5,-0.5,-0.5)
#define  P1  vec3 ( 0.5,-0.5,-0.5)
#define  P4  vec3 (-0.5,-0.5, 0.5)
#define  P5  vec3 ( 0.5,-0.5, 0.5)
#define  P6  vec3 (-0.5, 0.5, 0.5)

#define  PX  vec3 ( 1.0, 0.0, 0.0)
#define  PY  vec3 ( 0.0, 1.0, 0.0)
#define  PZ  vec3 ( 0.0, 0.0, 1.0)
#define  NX  vec3 (-1.0, 0.0, 0.0)
#define  NZ  vec3 ( 0.0, 0.0,-1.0)

#define YELLOW vec4 (1.0, 1.0, 0.0, 1.0)
#define RED vec4 (1.0, 0.0, 0.0, 1.0)
#define GREE vec4 (0.0, 1.0, 0.0, 1.0)
#define BLUE vec4 (0.0, 0.0, 1.0, 1.0)



precision mediump float;
varying vec2 vTextureCoord;
uniform samplerExternalOES sTexture;

//
vec2 rectangle_transform_cube(vec2 coord){
    vec2 result;
    int face = -1;

    vec3 p;
    vec3 vx;
    vec3 vy;

    coord.y = 1.0 - coord.y;
    int vface = int (coord.y * float(2));
    int hface = int (coord.x * float(3));
    coord.x = coord.x * 3.0 - float(hface);
    coord.y = coord.y * 2.0 - float(vface);
    face = hface + (1-vface) * 3;
    if(face == RIGHT){
        p = P5; vx = NZ; vy = PY;
    }
    else if(face == LEFT){
        p = P0; vx = PZ; vy = PY;
    }
    else if(face == TOP){
         p = P6; vx = PX; vy = NZ;
    }
    else if(face == BOTTOM){
         p = P0; vx = PX; vy = PZ;
    }
    else if(face == FRONT){
         p = P4; vx = PX; vy = PY;
    }
    else {
         p = P1; vx = NX; vy = PY;
    }
    coord.x = (coord.x - 0.5) * 1.01 + 0.5;
    coord.y = (coord.y - 0.5) * 1.01 + 0.5;
    vec3 temp;
    temp.x = p.x + vx.x * coord.x + vy.x * coord.y;
    temp.y = p.y + vx.y * coord.x + vy.y * coord.y;
    temp.z = p.z + vx.z * coord.x + vy.z * coord.y;

    float d = length(temp);

    result.x = -atan((-temp.x) / d, temp.z / d) / (PI * 2.0) +0.5;
    result.y = asin((-temp.y) / d) / PI + 0.5;

    return result;
}

//transform top part
vec2 cube_transfrom_rectanle_top(float x_angle, float y_angle){
    vec2 rst;
    float x_dis = sin(x_angle) * tan(PI / 2.0 - y_angle);
    float y_dis = -(cos(x_angle) * tan(PI / 2.0 -y_angle));

    float temp_center_x = 5.0 / 6.0;
    float temp_center_y = 1.0 / 4.0;

    float x_pos = temp_center_x + x_dis * 1.0 / 6.0;
    float y_pos = temp_center_y - y_dis * 1.0 / 4.0;
    rst.x = x_pos;
    rst.y = y_pos;
    return rst;
}

//transform bottom part
vec2 cube_transfrom_rectanle_bottom(float x_angle, float y_angle){
    vec2 rst;

    float x_dis = -(sin(x_angle) * tan(PI / 2.0 - y_angle));
    float y_dis = -(cos(x_angle) * tan(PI / 2.0 -y_angle));

    float temp_center_x = 1.0 / 6.0;
    float temp_center_y = 3.0 / 4.0;

    float x_pos = temp_center_x + x_dis * 1.0 / 6.0;
    float y_pos = temp_center_y - y_dis * 1.0 / 4.0;

    rst.x = x_pos;
    rst.y = y_pos;
    return rst;
}


vec2 cube_transfrom_rectanle(vec2 coord){
    vec2 result;
    float x_angle = 0.0;
    float y_angle = 0.0;
    float x_dis = 0.0;
    float y_dis = 0.0;
    float x_pos = 0.0;
    float y_pos = 0.0;

    //水平方向，求出角度 -PI ~ PI
    if(0.5 <= coord.x){
        x_angle = -((0.5 - coord.x) * 2.0 * PI);
    }else{
        x_angle = (coord.x + 0.5 - 1.0) * 2.0 * PI;
    }

    //垂直方向，求出角度 PI/2 ~ -PI/2
    if(0.5 <= coord.y){
        y_angle = ((0.5- coord.y) * PI );
    }else{
        y_angle = -((coord.y + 0.5 - 1.0) * PI);
    }

    //根据角度判断方向
    if(y_angle > -(PI / 4.0) && y_angle < PI / 4.0){
        //前
        if( x_angle >= -(PI / 4.0) && x_angle < PI /4.0){
            //获取该点相对该面中心位置的距离比例
            x_dis = (tan(x_angle) + 1.0)/ 2.0;
            y_dis = ((-tan(y_angle) / cos (x_angle)) + 1.0) / 2.0;

            //上面
            if(y_dis < 0.0){
                result = cube_transfrom_rectanle_top(x_angle,y_angle);
            }
            //下面
            else if(y_dis > 1.0){
                  result = cube_transfrom_rectanle_bottom(x_angle,y_angle);
            }else{
                //求出该点在cube画面的位置
                x_pos = 1.0 / 3.0 * x_dis + 1.0 / 3.0;
                y_pos = 1.0 / 2.0 * y_dis + 1.0 / 2.0;

                result.x = x_pos;
                result.y = y_pos;
            }
        }
        //右边
        else if (x_angle >= PI / 4.0 && x_angle < PI * 3.0 /4.0){
            x_dis = (tan(x_angle - PI / 2.0 ) + 1.0 )/ 2.0;
            y_dis = ((-tan(y_angle) / cos(x_angle - PI / 2.0)) + 1.0) / 2.0;

            if(y_dis < 0.0){
                  result = cube_transfrom_rectanle_top(x_angle,y_angle);
            }
            else if(y_dis > 1.0){
                  result = cube_transfrom_rectanle_bottom(x_angle,y_angle);
            }else{
                x_pos = 1.0 / 3.0 * x_dis ;
                y_pos = 1.0 / 2.0 * y_dis ;

                result.x = x_pos;
                result.y = y_pos;
            }
        }
        //后边
        else if( (x_angle >= PI * 3.0 / 4.0 && x_angle <= PI) || (x_angle >= -PI && x_angle < -(PI * 3.0 / 4.0))){
            float temp_angle = x_angle;

            if(x_angle >= PI * 3.0 / 4.0 && x_angle <= PI){
                temp_angle = x_angle - PI;
                x_dis = (tan(temp_angle) + 1.0 )/ 2.0;
            }
            if(x_angle >= -PI && x_angle < -(PI * 3.0 / 4.0)){
               temp_angle = PI + x_angle;
               x_dis = (tan(temp_angle) + 1.0 )/ 2.0;
            }

            y_dis = ((-tan(y_angle)/ cos(temp_angle)) + 1.0) / 2.0;

            if(y_dis < 0.0){
                result = cube_transfrom_rectanle_top(x_angle,y_angle);
            }
            else if(y_dis > 1.0){
                result = cube_transfrom_rectanle_bottom(x_angle,y_angle);
            }else{
                x_pos = 1.0 / 3.0 * x_dis + 2.0 / 3.0;
                y_pos = 1.0 / 2.0 * y_dis + 1.0 / 2.0;

                result.x = x_pos;
                result.y = y_pos;
            }
        }
        //左边
        else if (x_angle >= -(PI *3.0 / 4.0) && x_angle < -(PI  / 4.0)){
            x_dis = (tan(x_angle + PI / 2.0 ) + 1.0 )/ 2.0;
            y_dis = ((-tan(y_angle)/cos(x_angle + PI / 2.0)) + 1.0) / 2.0;

            if(y_dis < 0.0){
                result = cube_transfrom_rectanle_top(x_angle,y_angle);
            }
            else if(y_dis > 1.0){
                result = cube_transfrom_rectanle_bottom(x_angle,y_angle);
            }else{
                x_pos = 1.0 / 3.0 * x_dis  + 1.0 / 3.0;
                y_pos = 1.0 / 2.0 * y_dis ;

                result.x = x_pos;
                result.y = y_pos;
            }
        }
    }
    //上边
    else if(y_angle > PI / 4.0 ){
        result = cube_transfrom_rectanle_top(x_angle,y_angle);
    }
    //下边
    else if(y_angle < - (PI / 4.0)){
        result = cube_transfrom_rectanle_bottom(x_angle,y_angle);
    }
    return result;
}

void main() {
    vec2 vNewTextureCoord = cube_transfrom_rectanle(vTextureCoord);
    gl_FragColor = texture2D(sTexture, vNewTextureCoord);
}

