--Woodland Dancer
--If this card is Normal Summoned: You can target 1 Equip Spell Card in your Graveyard; 
--Equip it to an appropriate target on the field. Once per turn: You can tribute 1 monster
--that is equipped with an Equip Spell Card you control; Special Summon 1 Plant-Type Monster
--from your Deck or Graveyard. 

function c79854526.initial_effect(c)
--equip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c79854526.target)
	e1:SetOperation(c79854526.operation)
	c:RegisterEffect(e1)
	--lonefire
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79854526,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c79854526.lcost)
	e2:SetTarget(c79854526.ltarget)
	e2:SetOperation(c79854526.loperation)
	c:RegisterEffect(e2)

end
--equip
function c79854526.tcfilter(tc,ec)
	return tc:IsFaceup() and ec:CheckEquipTarget(tc)
end
function c79854526.ecfilter(c)
	return c:IsType(TYPE_EQUIP) and Duel.IsExistingTarget(c79854526.tcfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
function c79854526.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		if not Duel.IsExistingTarget(c79854526.ecfilter,tp,LOCATION_GRAVE,0,1,nil) then return false end
		if e:GetHandler():IsLocation(LOCATION_HAND) then
			return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		else return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25067275,0))
	local g=Duel.SelectTarget(tp,c79854526.ecfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local ec=g:GetFirst()
	e:SetLabelObject(ec)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25067275,1))
	Duel.SelectTarget(tp,c79854526.tcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,ec:GetEquipTarget(),ec)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,ec,1,0,0)
end
function c79854526.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local ec=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	if ec:IsFaceup() and ec:IsRelateToEffect(e) then 
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			Duel.Equip(tp,ec,tc)
		end
	end
end
--lonefire
function c79854526.lcostfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:GetEquipCount()>0
end
function c79854526.lcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c79854526.lcostfilter,1,nil) end
	local g=Duel.SelectReleaseGroup(tp,c79854526.lcostfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function c79854526.lfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c79854526.ltarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(c79854526.lfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_GRAVE+LOCATION_DECK)
end
function c79854526.loperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c79854526.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end