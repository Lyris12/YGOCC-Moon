--Monkastery Commons

Monkastery=Monkastery or {}

Monkastery.Code = 0x252
function Monkastery.Is(c, ignore_facedown)
	if (ignore_facedown==nil) then ignore_facedown=false end
	return c:IsSetCard(Monkastery.Code) and (ignore_facedown or (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED+LOCATION_ONFIELD)))
end

function Monkastery.SharedEffects(c)
	local code=c:GetOriginalCode()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(code,0))
	e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_QUICK_O+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,code)
	e1:SetCondition(function(e,tp,eg,ep,ev,re) return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) end)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(code,1))
	e2:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re:GetActiveType()==TYPE_TRAP and rp==tp end)
	e2:SetCountLimit(1,{code,1})
	return e1,e2
end

function Monkastery.UsedFilter(c,code)
	local re=c:GetReasonEffect()
	local rc=c:GetReasonCard()
	return Monkastery.Is(c) and Duel.GetTurnCount()==c:GetTurnID()
		and ((re and re:GetHandler():IsCode(code)) or (rc and rc:IsCode(code)))
end
