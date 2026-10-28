package feature.regresion;

import com.intuit.karate.junit5.Karate;

class RegresionRunner {

    @Karate.Test
    Karate testRegresion() {
        return Karate.run("regresion").relativeTo(getClass());
    }
}
