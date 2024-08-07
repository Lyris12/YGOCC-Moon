--Sonic Ninja
--created by Meedogh, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,aux.FilterBoolFunction(Card.IsCode,81455790),1,aux.NOT(aux.FilterEqualFunction(Card.GetVibe,0)),1)
	aux.AddCodeList(c,81455790)
	aux.AddMaterialCodeList(c,81455790)
	--Once per turn: You can Special Summon 1 "Cosmo'n" monster or a Bigbang Monster that mentions a "Cosmo'n" monster as material from your GY.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	--Once per turn: You can destroy 1 Monster Card in your Spell/Trap Zone; destroy 1 monster your opponent controls, then you can add 1 "Cosmo'n" monster from your GY to your hand.
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetCost(s.cost)
	e2:SetTarget(s.dtg)
	e2:SetOperation(s.dop)
	c:RegisterEffect(e2)
	--If this card is destroyed: You can Special Summon 1 "Cosmo'n" monster from your Deck or GY.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.material_setcode=0xcf11
function s.filter(c,e,tp)
	return (c:IsSetCard(0xcf11) or (aux.IsMaterialListSetCard(c,0xcf11) and c:IsType(TYPE_BIGBANG))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end
function s.cfilter(c)
	return (aux.GetOriginalPandemoniumType(c)~=nil and c:GetSequence()<5 or c:GetOriginalType()&TYPE_MONSTER~=0)
		and c:IsDestructable()
end
function s.thfilter(c)
	return c:IsSetCard(0xcf11) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_SZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.Destroy(g:Select(tp,1,1,nil),REASON_COST)
end
function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #dg>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if Duel.Destroy(g,REASON_EFFECT)==0 then return end
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,nil)
	if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local tc=tg:Select(tp,1,1,nil)
		Duel.BreakEffect()
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xcf11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end
