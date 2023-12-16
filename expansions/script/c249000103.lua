--Radiant Summoner Knight LV4
xpcall(function() require("expansions/script/bannedlist") end,function() require("script/bannedlist") end)
function c249000103.initial_effect(c)
	--special summon lvlup
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(2)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c249000103.spcon)
	e1:SetTarget(c249000103.sptg)
	e1:SetOperation(c249000103.spop)
	c:RegisterEffect(e1)
	--special summon create
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(509)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c249000103.cost)
	e2:SetTarget(c249000103.target)
	e2:SetOperation(c249000103.operation)
	c:RegisterEffect(e2)
end
c249000103.lvupcount=1
c249000103.lvup={249000104}
c249000103.summonable_code_table={249000103,OPCODE_ISCODE,249000106,OPCODE_ISCODE,OPCODE_OR,249000107,OPCODE_ISCODE,OPCODE_OR,249000109,OPCODE_ISCODE,OPCODE_OR,249000110,OPCODE_ISCODE,OPCODE_OR}
function c249000103.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
function c249000103.spfilter(c,e,tp)
	return c:IsCode(249000104) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function c249000103.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c249000103.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function c249000103.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown()
		or not Duel.IsExistingMatchingCard(c249000103.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249000103.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SendtoGrave(c,REASON_EFFECT)
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function c249000103.costfilter(c)
	return c:IsSetCard(0x41) and c:IsAbleToRemoveAsCost()
end
function c249000103.costfilter2(c,e)
	return c:IsSetCard(0x41) and not c:IsPublic()
end
function c249000103.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(c249000103.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000103.costfilter2,tp,LOCATION_HAND,0,1,nil,e)) end
	local option
	if Duel.IsExistingMatchingCard(c249000103.costfilter2,tp,LOCATION_HAND,0,1,nil,e)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000103.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000103.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000103.costfilter2,tp,LOCATION_HAND,0,1,nil,e) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000103.costfilter2,tp,LOCATION_HAND,0,1,1,nil,e)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000103.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249000103.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function c249000103.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local ac
	local cc
	repeat
		ac=Duel.AnnounceCardFilter(tp,table.unpack(c249000103.summonable_code_table))
		if ac==249000103 then return end
		cc=Duel.CreateToken(tp,ac)
	until cc:IsCanBeSpecialSummoned(e,0,tp,true,false) and not banned_list_table[ac]
	if Duel.SpecialSummonStep(cc,0,tp,tp,true,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1,true)
		aux.CannotBeEDMaterial(cc,nil,LOCATION_MZONE,true,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		cc:CompleteProcedure()
	end
	Duel.SpecialSummonComplete()
end