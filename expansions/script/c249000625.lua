--Spell-Disciple Xyz Sage
xpcall(function() require("expansions/script/bannedlist") end,function() require("script/bannedlist") end)
function c249000625.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c249000625.spcon)
	e1:SetOperation(c249000625.spop)
	c:RegisterEffect(e1)
	--xyz summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c249000625.condition)
	e2:SetCost(c249000625.cost)
	e2:SetTarget(c249000625.target)
	e2:SetOperation(c249000625.operation)
	c:RegisterEffect(e2)
end
function c249000625.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND,0,1,c,0x1D9)
end
function c249000625.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_HAND,0,1,1,c,0x1D9)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function c249000625.confilter(c)
	return c:IsSetCard(0x1D9) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:GetCode()~=249000625
end
function c249000625.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c249000625.confilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>0
end
function c249000625.costfilter(c)
	return c:IsSetCard(0x1D9) and c:IsAbleToRemoveAsCost()
end
function c249000625.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000625.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249000625.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249000625.targetfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and (c:GetLevel()>0 or c:GetRank()>0)
end
function c249000625.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return (chkc:IsOnField() or chkc:IsLocation(LOCATION_GRAVE)) end
	if chk==0 then return Duel.IsExistingTarget(c249000625.targetfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) and Duel.GetLocationCountFromEx(tp,tp,e:GetHandler())>0 end
	local g=Duel.SelectTarget(tp,c249000625.targetfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
end
function c249000625.codefilter(c,code)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCode(code)
end
function c249000625.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) and Duel.GetLocationCountFromEx(tp,tp,c)>0 then
		local lvrk
		if tc:GetRank() > 0 then lvrk=tc:GetRank() else lvrk=tc:GetLevel() end
		local ac=Duel.AnnounceCardFilter(tp,tc:GetOriginalRace(),OPCODE_ISRACE,tc:GetOriginalAttribute(),OPCODE_ISATTRIBUTE,OPCODE_AND,TYPE_XYZ,OPCODE_ISTYPE,OPCODE_AND,249000625,OPCODE_ISCODE,OPCODE_OR)
		if ac==249000625 then return end
		local cc=Duel.CreateToken(tp,ac)
		while not (cc:IsType(TYPE_XYZ) and (cc:GetRank()-lvrk <=2 or cc:GetRank()-lvrk >=-2) and not banned_list_table[ac] and
		cc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)	and cc:IsRace(tc:GetRace()) and cc:IsAttribute(tc:GetAttribute()) and not Duel.IsExistingMatchingCard(c249000625.codefilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,ac))
		do
			ac=Duel.AnnounceCardFilter(tp,tc:GetOriginalRace(),OPCODE_ISRACE,tc:GetOriginalAttribute(),OPCODE_ISATTRIBUTE,OPCODE_AND,TYPE_XYZ,OPCODE_ISTYPE,OPCODE_AND,249000625,OPCODE_ISCODE,OPCODE_OR)
			if ac==249000625 then return end
			cc=Duel.CreateToken(tp,ac)
		end
		Duel.SendtoDeck(cc,nil,0,REASON_RULE)
		cc:SetMaterial(Group.FromCards(c))
		Duel.Overlay(cc,c)
		Duel.SpecialSummon(cc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		local tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
		if tc2 then
			Duel.Overlay(cc,tc2)
		end
		cc:CompleteProcedure()
	end
end