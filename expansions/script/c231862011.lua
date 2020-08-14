--created by ZEN, coded by TaxingCorn117 & Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddLinkProcedure(c,nil,2,99,cid.lcheck)
	c:EnableReviveLimit()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
	e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
	e2:SetCountLimit(1,id+2000)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_DAMAGE)
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetCountLimit(1,id)
	e6:SetCondition(cid.rmcon)
	e6:SetOperation(cid.rmop)
	c:RegisterEffect(e6)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
	e3:SetCountLimit(1,id+1000)
	e3:SetCondition(aux.exccon)
	e3:SetTarget(cid.spstg)
	e3:SetOperation(cid.spsop)
	c:RegisterEffect(e3)
end
function cid.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x52f)
end
function cid.filter(c,e,tp,zone)
	return c:IsSetCard(0x52f) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone()
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp,zone) end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,500)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Damage(tp,500,REASON_EFFECT)==0 or Duel.GetLP(tp)<=0 then return end
	local c=e:GetHandler()
	local zone=c:GetLinkedZone()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp,zone)
	if #g>0 then
		Duel.BreakEffect()
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function cid.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetControler()==ep and ev>=500
end
function cid.rmop(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if Duel.IsChainDisablable(0) and #hg>0
		and Duel.SelectYesNo(1-tp,aux.Stringid(math.floor(id/100),2)) then
		Duel.DiscardHand(1-tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil)
		Duel.NegateEffect(0)
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function cid.checkzone(tp)
	local zone=0
	local g=Duel.GetMatchingGroup(cid.cfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		zone=bit.bor(zone,tc:GetLinkedZone(tp))
	end
	return bit.band(zone,0x1f)
end
function cid.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=cid.checkzone(tp)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1500)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function cid.spsop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Damage(tp,1500,REASON_EFFECT)==0 or Duel.GetLP(tp)<=0 then return end
	local zone=cid.checkzone(tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
