--Evolution-Burst
xpcall(function() require("expansions/script/bannedlist") end,function() require("script/bannedlist") end)
function c249001074.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c249001074.cost)
	e1:SetTarget(c249001074.target)
	e1:SetOperation(c249001074.activate)
	c:RegisterEffect(e1)
end
function c249001074.costfilter(c)
	return c:IsSetCard(0xC048) and c:IsAbleToDeckOrExtraAsCost()
end
function c249001074.costfilter2(c,e)
	return c:IsSetCard(0xC048) and not c:IsPublic()
end
function c249001074.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (Duel.IsExistingMatchingCard(c249001073.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249001073.costfilter2,tp,LOCATION_HAND,0,1,c)) end
	local option
	if Duel.IsExistingMatchingCard(c249001073.costfilter2,tp,LOCATION_HAND,0,1,c)  then option=0 end
	if Duel.IsExistingMatchingCard(c249001073.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249001073.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249001073.costfilter2,tp,LOCATION_HAND,0,1,c) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249001073.costfilter2,tp,LOCATION_HAND,0,1,1,c)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249001073.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SendtoDeck(g,nil,2,POS_FACEUP,REASON_COST)
	end
end
function c249001074.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xC048) and not c:IsType(TYPE_XYZ)
end
function c249001074.spfilter2(c,e,tp,mc)
	return aux.IsCodeListed(c,mc:GetCode()) and c:IsSetCard(0xC048) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function c249001074.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c249001073.spfilter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c249001073.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c249001073.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249001074.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	local sc
	local ac
	repeat
		ac=Duel.AnnounceCardFilter(tp,0xC048,OPCODE_ISSETCARD,TYPE_XYZ,OPCODE_ISTYPE,OPCODE_AND)
		sc=Duel.CreateToken(tp,ac)
	until aux.IsCodeListed(sc,tc:GetCode())
	if banned_list_table[ac] then return end
	Duel.SendtoDeck(sc,nil,0,REASON_RULE)
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249001073.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,Group.FromCards(tc))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,true,false,POS_FACEUP)
		sc:CompleteProcedure()
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
        	c:CancelToGrave()
        	Duel.Overlay(sc,Group.FromCards(c))
        end
	end
end