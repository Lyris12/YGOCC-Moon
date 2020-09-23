--Disciple of Dark Magic LV6
function c249000169.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(2)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c249000169.spcon)
	e1:SetTarget(c249000169.sptg)
	e1:SetOperation(c249000169.spop)
	c:RegisterEffect(e1)
	--weaken
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c249000169.cost)
	e2:SetTarget(c249000169.target)
	e2:SetOperation(c249000169.operation)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(2)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c249000169.spcost)
	e3:SetTarget(c249000169.sptg)
	e3:SetOperation(c249000169.spop)
	c:RegisterEffect(e3)
end
c249000169.lvup={249000170}
c249000169.lvdn={249000168}
function c249000169.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
function c249000169.spfilter(c,e,tp)
	return c:IsCode(249000170) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function c249000169.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c249000169.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function c249000169.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown()
		or not Duel.IsExistingMatchingCard(c249000169.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249000169.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SendtoGrave(c,REASON_EFFECT)
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function c249000169.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function c249000169.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFaceup() and c249000169.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,2,nil)
end
function c249000169.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		if tc:IsFaceup() then
			if tc:IsType(TYPE_SPELL+TYPE_TRAP) then 
				Duel.Destroy(tc,REASON_EFFECT)
			else
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(-2000)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				tc:RegisterEffect(e2)
				--destroy
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				e3:SetCode(EFFECT_SELF_DESTROY)
				e3:SetCondition(c249000169.descon)
				tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
		end
	end
end
function c249000169.descon(e)
	local tc=e:GetHandler()
	return tc and tc:GetAttack()==0 or (not tc:IsType(TYPE_LINK) and tc:GetDefense()==0)
end
function c249000169.spcostfilter(c)
	return c:IsLevelAbove(1) and c:IsAbleToRemoveAsCost() and c:IsRace(RACE_SPELLCASTER)
end
function c249000169.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c249000169.spcostfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckWithSumGreater(Card.GetLevel,8) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:SelectWithSumGreater(tp,Card.GetLevel,8)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end