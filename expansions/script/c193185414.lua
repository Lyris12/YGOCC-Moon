--created by Swag, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,cid.mfilter,3,3)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(function(e,tc) return tc==e:GetHandler() or e:GetHandler():GetLinkedGroup():IsContains(tc) end)
	e1:SetValue(function(e,c) return Duel.GetMatchingGroupCount(cid.afilter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,nil)*200 end)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
	e3:SetTarget(cid.sumtg)
	e3:SetOperation(cid.sumop)
	c:RegisterEffect(e3)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(cid.cost)
	e2:SetTarget(cid.copytg)
	e2:SetOperation(cid.copyop)
	c:RegisterEffect(e2)
end
function cid.mfilter(c)
	return c:IsLinkRace(RACE_ZOMBIE) and not c:IsType(TYPE_TOKEN)
end
function cid.afilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_TIMELEAP)
end
function cid.filter(c,e,sp)
	return c:IsSetCard(0xd78) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
function cid.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cid.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(cid.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,Duel.SelectTarget(tp,cid.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp),1,0,0)
end
function cid.sumop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
function cid.cfilter(c,g)
	return g:IsContains(c)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	if chk==0 then return Duel.CheckReleaseGroup(tp,cid.cfilter,1,nil,lg) end
	local g=Duel.SelectReleaseGroup(tp,cid.cfilter,1,1,nil,lg)
	Duel.Release(g,REASON_COST)
end
function cid.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() and not chkc:IsLevelAbove(1) end
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsFaceup,aux.NOT(Card.IsLevelAbove)),tp,0,LOCATION_MZONE,1,nil,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.AND(Card.IsFaceup,aux.NOT(Card.IsLevelAbove)),tp,0,LOCATION_MZONE,1,1,nil,1)
end
function cid.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1) end
end
