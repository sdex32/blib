unit BRayTrace;

interface


type


      BTRT_Scene = object
//         Camera

      end;
      BTRT_Canvas = object
         private
            Xlng :longword;
            Ylng :longword;
            TheCanvas :pointer;
         public

      end;
      BTRT_Render = object
         private
            Canvas : BTRT_Canvas;
            Scene  : BTRT_Scene;
         public
//          function Render(Xpos,Ypos,Xlng,Ylng:longint);

      end;




type  BTRT_Color = record
        R,G,B:single;
      end;


      BTRayTrace = class
         private
            aResBufXlng :longword;
            aResBufYlng :longword;

            function    _CastRayForPixel(x,y:longword):BTRT_Color;
         public
            constructor Create(Xlng,Ylng,SuperSampels:longword);
            destructor  Destroy; override;
            procedure   RayTrace(filename:string);
      end;


implementation


constructor BTRayTrace.Create(Xlng,Ylng,SuperSampels:longword);
begin

end;

destructor  BTRayTrace.Destroy;
begin

   inherited;
end;


procedure   BTRayTrace.RayTrace(filename:string);
var x,y:longword;
    RawCompleted:longword;
    percentage:single;
begin
   RawCompleted := 0;

(*
string fileName) {
   int columnsCompleted = 0;
   camera.calculateWUV();
   Image image(width, height);

   // Reset depthComplexity to avoid unnecessary loops.
   if (dispersion < 0) {
      depthComplexity = 1;
   }

   imageScale = camera.screenWidth / (float)width;

   #pragma omp parallel for
   for (int x = 0; x < width; x++) {
      // Update percent complete.
      columnsCompleted++;
      float percentage = columnsCompleted/(float)width * 100;
      cout << '\r' << (int)percentage << '%';
      fflush(stdout);

      for (int y = 0; y < height; y++) {
         image.pixel(x, y, castRayForPixel(x, y));
      }
   }

   cout << "\rDone!" << endl;
   cout << "Rays cast: " << raysCast << endl;

   image.WriteTga(fileName.c_str(), false);
*)

   for  y := 0 to (aResBufYlng - 1) do
   begin
      for x := 0 to (aResBufXlng - 1) do
      begin
//         image.pixel(x, y, _CastRayForPixel(x, y));

      end;
      inc(RawCompleted);
      percentage := (RawCompleted/aResBufYlng) * 100;
   end;
end;



function    BTRayTrace._CastRayForPixel(x,y:longword):BTRT_Color;
begin

end;
 (*
   double rayX = (x - width / 2)/2.0;
   double rayY = (y - height / 2)/2.0;
   double pixelWidth = rayX - (x + 1 - width / 2)/2.0;
   double sampleWidth = pixelWidth / superSamples;
   double sampleStartX = rayX - pixelWidth/2.0;
   double sampleStartY = rayY - pixelWidth/2.0;
   double sampleWeight = 1.0 / (superSamples * superSamples);
   Color color;

   for (int x = 0; x < superSamples; x++) {
      for (int y = 0; y < superSamples; y++) {
         Vector imagePlanePoint = camera.lookAt -
          (camera.u * (sampleStartX + (x * sampleWidth)) * imageScale) +
          (camera.v * (sampleStartY + (y * sampleWidth)) * imageScale);

         color = color + (castRayAtPoint(imagePlanePoint) * sampleWeight);
      }
   }

   return color;
*)

(*
Color RayTracer::castRayAtPoint(const Vector& point) {
   Color color;

   for (int i = 0; i < depthComplexity; i++) {
      Ray viewRay(camera.position, point - camera.position, maxReflections,
       startingMaterial);

      if (depthComplexity > 1) {
         Vector disturbance(
          (dispersion / RAND_MAX) * (1.0f * rand()),
          (dispersion / RAND_MAX) * (1.0f * rand()),
          0.0f);

         viewRay.origin = viewRay.origin + disturbance;
         viewRay.direction = point - viewRay.origin;
         viewRay.direction = viewRay.direction.normalize();
      }

      color = color + (castRay(viewRay) * (1 / (float)depthComplexity));
   }

   return color;
}

Color RayTracer::castRay(const Ray& ray) {
   raysCast++;
   Intersection intersection = getClosestIntersection(ray);

   if (intersection.didIntersect) {
      return performLighting(intersection);
   } else {
      return Color();
   }
}
*)
(*
bool RayTracer::isInShadow(const Ray& ray, double lightDistance) {
   Intersection intersection = getClosestIntersection(ray);

   return intersection.didIntersect && intersection.distance < lightDistance;
}

Intersection RayTracer::getClosestIntersection(const Ray& ray) {
   // Merely use the BSP for intersections.
   return bsp->getClosestIntersection(ray);
}

Color RayTracer::performLighting(const Intersection& intersection) {
   Color color = intersection.getColor();
   Color ambientColor = getAmbientLighting(intersection, color);
   Color diffuseAndSpecularColor = getDiffuseAndSpecularLighting(intersection, color);
   Color reflectedColor = getReflectiveRefractiveLighting(intersection);

   return ambientColor + diffuseAndSpecularColor + reflectedColor;
}

Color RayTracer::getAmbientLighting(const Intersection& intersection, const Color& color) {
   return color * 0.2;
}

Color RayTracer::getDiffuseAndSpecularLighting(const Intersection& intersection,
 const Color& color) {
   Color diffuseColor(0.0, 0.0, 0.0);
   Color specularColor(0.0, 0.0, 0.0);

   for (vector<Light*>::iterator itr = lights.begin(); itr < lights.end(); itr++) {
      Light* light = *itr;
      Vector lightOffset = light->position - intersection.intersection;
      double lightDistance = lightOffset.length();
      /**
       * TODO: Be careful about normalizing lightOffset too.
       */
      Vector lightDirection = lightOffset.normalize();
      double dotProduct = intersection.normal.dot(lightDirection);

      /**
       * Intersection is facing light.
       */
      if (dotProduct >= 0.0f) {
         Ray shadowRay = Ray(intersection.intersection, lightDirection, 1,
          intersection.ray.material);

         if (isInShadow(shadowRay, lightDistance)) {
            /**
             * Position is in shadow of another object - continue with other lights.
             */
            continue;
         }

         diffuseColor = (diffuseColor + (color * dotProduct)) *
          light->intensity;
         specularColor = specularColor + getSpecularLighting(intersection, light);
      }
   }

   return diffuseColor + specularColor;
}

Color RayTracer::getSpecularLighting(const Intersection& intersection,
 Light* light) {
   Color specularColor(0.0, 0.0, 0.0);
   double shininess = intersection.endMaterial->getShininess();

   if (shininess == NOT_SHINY) {
      /* Don't perform specular lighting on non shiny objects. */
      return specularColor;
   }

   Vector view = (intersection.ray.origin - intersection.intersection).normalize();
   Vector lightOffset = light->position - intersection.intersection;
   Vector reflected = reflectVector(lightOffset.normalize(), intersection.normal);

   double dot = view.dot(reflected);

   if (dot <= 0) {
      return specularColor;
   }

   double specularAmount = pow(dot, shininess) * light->intensity;

   specularColor.r = specularAmount;
   specularColor.g = specularAmount;
   specularColor.b = specularAmount;

   return specularColor;
}

Color RayTracer::getReflectiveRefractiveLighting(const Intersection& intersection) {
   double reflectivity = intersection.endMaterial->getReflectivity();
   double startRefractiveIndex = intersection.startMaterial->getRefractiveIndex();
   double endRefractiveIndex = intersection.endMaterial->getRefractiveIndex();
   int reflectionsRemaining = intersection.ray.reflectionsRemaining;

   /**
    * Don't perform lighting if the object is not reflective or refractive or we have
    * hit our recursion limit.
    */
   if (reflectivity == NOT_REFLECTIVE && endRefractiveIndex == NOT_REFRACTIVE ||
    reflectionsRemaining <= 0) {
      return Color();
   }

   // Default to exclusively reflective values.
   double reflectivePercentage = reflectivity;
   double refractivePercentage = 0;

   // Refractive index overrides the reflective property.
   if (endRefractiveIndex != NOT_REFRACTIVE) {
      reflectivePercentage = getReflectance(intersection.normal,
       intersection.ray.direction, startRefractiveIndex, endRefractiveIndex);

      refractivePercentage = 1 - reflectivePercentage;
   }

   // No ref{ra,le}ctive properties - bail early.
   if (refractivePercentage <= 0 && reflectivePercentage <= 0) {
      return Color();
   }

   Color reflectiveColor;
   Color refractiveColor;

   if (reflectivePercentage > 0) {
      Vector reflected = reflectVector(intersection.ray.origin,
       intersection.normal);
      Ray reflectedRay(intersection.intersection, reflected, reflectionsRemaining - 1,
       intersection.ray.material);

      reflectiveColor = castRay(reflectedRay) * reflectivePercentage;
   }

   if (refractivePercentage > 0) {
      Vector refracted = refractVector(intersection.normal,
       intersection.ray.direction, startRefractiveIndex, endRefractiveIndex);
      Ray refractedRay = Ray(intersection.intersection, refracted, 1,
       intersection.endMaterial);

      refractiveColor = castRay(refractedRay) * refractivePercentage;
   }

   return reflectiveColor + refractiveColor;
}

double RayTracer::getReflectance(const Vector& normal, const Vector& incident,
 double n1, double n2) {
   double n = n1 / n2;
   double cosI = -normal.dot(incident);
   double sinT2 = n * n * (1.0 - cosI * cosI);

   if (sinT2 > 1.0) {
      // Total Internal Reflection.
      return 1.0;
   }

   double cosT = sqrt(1.0 - sinT2);
   double r0rth = (n1 * cosI - n2 * cosT) / (n1 * cosI + n2 * cosT);
   double rPar = (n2 * cosI - n1 * cosT) / (n2 * cosI + n1 * cosT);
   return (r0rth * r0rth + rPar * rPar) / 2.0;
}

Vector RayTracer::refractVector(const Vector& normal, const Vector& incident,
 double n1, double n2) {
   double n = n1 / n2;
   double cosI = -normal.dot(incident);
   double sinT2 = n * n * (1.0 - cosI * cosI);

   if (sinT2 > 1.0) {
      cerr << "Bad refraction vector!" << endl;
      exit(EXIT_FAILURE);
   }

   double cosT = sqrt(1.0 - sinT2);
   return incident * n + normal * (n * cosI - cosT);
}

Vector RayTracer::reflectVector(Vector vector, Vector normal) {
   return normal * 2 * vector.dot(normal) - vector;
*)

end.
