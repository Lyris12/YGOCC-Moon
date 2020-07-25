--created by Pina, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO),7,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,te) return e:GetHandlerPlayer()~=te:GetOwnerPlayer() end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetCondition(cid.condition)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCategory(CATEGORY_RELEASE+CATEGORY_DESTROY)
	e3:SetCost(cid.descost)
	e3:SetTarget(cid.destg)
	e3:SetOperation(cid.desop)
	c:RegisterEffect(e3)
end
function cid.mfilter(c,tp)
	return c:IsRace(RACE_PLANT) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp
end
function cid.cfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetMaterial():IsExists(cid.mfilter,1,nil,tp)
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	return eg:IsExists(cid.cfilter,1,nil,tp)
end
function cid.filter(c,e,tp)
	local seq=c:GetSequence()
	return seq~=1 and seq~=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0) and c:IsRace(RACE_PLANT)
		and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetDecktopGroup(tp,1)+Duel.GetFieldCard(tp,LOCATION_DECK,1)
	if Duel.SendtoGrave(tg,REASON_EFFECT)==0 or tg:IsExists(aux.NOT(Card.IsLocation),1,nil,LOCATION_GRAVE) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		aux.CannotBeEDMaterial(tc,aux.TargetBoolFunction(Card.IsType,TYPE_SYNCHRO),LOCATION_MZONE,true,RESET_EVENT+RESETS_STANDARD)
	end
end
function cid.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,aux.AND(Card.IsRace,aux.OR(Card.IsFaceup,aux.NOT(Card.IsOnField)),Card.IsReleasableByEffect),1,nil,RACE_PLANT)
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD),1,0,0)
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Release(Duel.SelectReleaseGroupEx(tp,aux.AND(Card.IsRace,aux.OR(Card.IsFaceup,aux.NOT(Card.IsOnField)),Card.IsReleasableByEffect),1,1,nil,RACE_PLANT),REASON_EFFECT)==0 then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.GetMatchingGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
	Duel.HintSelection(g)
	Duel.Destroy(g,REASON_EFFECT)
end
