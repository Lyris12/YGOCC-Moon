function c160009292.initial_effect(c)
    aux.AddOrigPandemoniumType(c)
	
	  --Atk up
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
   -- e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK))
    e2:SetValue(500)
    c:RegisterEffect(e2)
    --Def down
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    e3:SetValue(-400)
    c:RegisterEffect(e3)
end
