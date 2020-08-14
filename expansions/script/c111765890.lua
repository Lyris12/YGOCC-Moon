--created by NTA, coded by Remnance
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cid.spcost)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
end
function cid.spfilter(c,e,tp)
	return c:IsSetCard(0x4578) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.thfilter(c)
	return c:IsCode(id) and c:IsAbleToHand()
end
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g1>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local g2=Duel.GetMatchingGroup(cid.thfilter,tp,LOCATION_DECK,0,nil)
		if g1:GetFirst():IsCode(id//100) and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id//100,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g2>0 then
			Duel.SendtoHand(g2,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		 end
	  end
   end
end