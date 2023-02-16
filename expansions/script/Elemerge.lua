--Elemerge Commons

Elemerge=Elemerge or {}

Elemerge.Code = 0x251
function Elemerge.Is(c) return c:IsSetCard(Elemerge.Code) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED+LOCATION_ONFIELD)) end

function Elemerge.GetAttributeCount(att,per)
	return math.floor(Duel.GetMatchingGroupCount(Elemerge.IsAttribute(att),0,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)/per)
end
function Elemerge.IsAttribute(att)
	return function(c) return c:IsAttribute(att) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED+LOCATION_ONFIELD))  end
end

function Elemerge.SummonLock(e)
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetTargetRange(1,0)
	e0:SetLabel(e:GetHandler():GetCode())
	e0:SetTarget(function(e0,c) return c:IsCode(e0:GetLabel()) end)
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,e:GetHandlerPlayer())
end

