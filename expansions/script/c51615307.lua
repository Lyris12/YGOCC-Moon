--created by LeonDuvall, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,5,function(e,tc) return not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),c:GetControler(),LOCATION_MZONE,0,1,nil,id) end,aux.FilterBoolFunction(Card.IsCode,id-6))
	aux.AddCodeList(c,id-6)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCondition(function(e,tp) return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP) and Duel.GetTurnPlayer()==tp end)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetTarget(s.tglim)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP),1,0,0)
	Duel.SetChainLimit(function(ef,rpr,p) return rpr==p or not ef:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP) end)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
function s.tglim(e,c)
	return c:IsFaceup() and c:IsSetCard(0xcfd) and not c:IsCode(id)
end
function s.efilter(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and rp~=e:GetHandlerPlayer()
end
