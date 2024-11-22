--[[
Manaseal Matriarch
Matriarca Manasigillo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	--[[While this card is attached to a DARK "Number" Xyz Monster, that monster is also treated as a "Manaseal" monster, also, each time a Spell Card or effect is activated, it gains 300 ATK
	immediately after that card or effect resolves.]]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_XMATERIAL)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCondition(s.setcodecon)
	e0:SetValue(ARCHE_MANASEAL)
	c:RegisterEffect(e0)
	local e0x=Effect.CreateEffect(c)
	e0x:SetDescription(id,2)
	e0x:SetType(EFFECT_TYPE_XMATERIAL|EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e0x:SetCode(EVENT_CHAINING)
	e0x:SetRange(LOCATION_MZONE)
	e0x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0x:SetOperation(s.regop)
	c:RegisterEffect(e0x)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,3)
	e1:SetType(EFFECT_TYPE_XMATERIAL|EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--[[If you control "Manaseal Rune Weaving" while this card is in your hand or GY: You can target 2 Spells in either GY; banish those targets face-down, and if you do, Special Summon this card,
	then send 1 "Manaseal Word" Trap from your hand or Deck to the GY.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_REMOVE|CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_MANASEAL_RUNE_WEAVING),LOCATION_ONFIELD,0,1),
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e2)
	--[[During your opponent's Main Phase (Quick Effect): You can target 3 other "Manaseal" cards and/or DARK monsters you control and/or in your GY (any combination of Monster Cards, or Normal or
	Counter Trap Cards); Special Summon 1 DARK "Number" Xyz Monster from your Extra Deck with a number between "201" and "214" in its name, except a "Number C" monster, by using this card and those
	targets as material (This is treated as an Xyz Summon).]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetFunctions(
		aux.MainPhaseCond(1),
		nil,
		s.sptg2,
		s.spop2
	)
	c:RegisterEffect(e3)
end

--E0 and E1
function s.setcodecon(e)
	local c=e:GetHandler()
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(ARCHE_NUMBER) and c:IsType(TYPE_XYZ)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if s.setcodecon(e) and re:IsActiveType(TYPE_SPELL) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_FACEDOWN|RESET_CHAIN,0,1)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return s.setcodecon(e) and e:GetHandler():GetFlagEffect(id)~=0 and re:IsActiveType(TYPE_SPELL)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,id)
	c:UpdateATK(300,true,e:GetOwner())
end

--E2
function s.tgfilter1(c,tp)
	return c:IsSpell() and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.tgfilter2(c)
	return c:IsSetCard(ARCHE_MANASEAL_WORD) and c:IsNormalTrap() and c:IsAbleToGrave()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.tgfilter1(chkc,tp) end
	if chk==0 then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExists(true,s.tgfilter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil,tp)
			and Duel.IsExists(false,s.tgfilter2,tp,LOCATION_HAND|LOCATION_DECK,0,1,c)
	end
	local g=Duel.Select(HINTMSG_REMOVE,true,tp,s.tgfilter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,2,nil,tp)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards():Filter(Card.IsSpell,nil)
	if #g>0 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter2,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end

--E3
function s.IsCanBeXyzMaterial_LessStrict(c,xyzc)
	if c:IsXyzType(TYPE_MONSTER) then return c:IsCanBeXyzMaterial(xyzc) end
	if c:IsForbidden() then return false end
	local eset={c:IsHasEffect(EFFECT_CANNOT_BE_XYZ_MATERIAL)}
	for _,e in ipairs(eset) do
		local res=e:Evaluate(xyzc)
		if res then
			return false
		end
	end
	return true
end
function s.targetchk(c)
	return c:IsFaceupEx() and (c:IsMonster() or c:IsNormalTrap() or c:IsTrap(TYPE_COUNTER))
		and (c:IsSetCard(ARCHE_MANASEAL) or (c:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and c:IsAttribute(ATTRIBUTE_DARK)))
end
function s.mfilter1(c,e)
	return s.targetchk(c) and c:IsCanBeEffectTarget(e)
end
function s.validxyzfilter(c,handler,e,tp)
	if not c:IsType(TYPE_XYZ) then return false end
	local no=aux.GetXyzNumber(c)
	return no and no>=201 and no<=214 and c:IsSetCard(ARCHE_NUMBER) and not c:IsSetCard(ARCHE_NUMBER_C) and c:IsAttribute(ATTRIBUTE_DARK)
		and handler:IsCanBeXyzMaterial(c) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.mcheck1(handler,sg)
	return	function(g,e,tp,mg,c)
				if #g==3 then
					g:AddCard(handler)
				end
				if #g<3 then return true end
				local mustchk=aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_XMATERIAL)
				if not mustchk then
					g:RemoveCard(handler)
					return false, false
				end
				local res=sg:IsExists(s.xyzfilter1,1,nil,e,tp,g,check)
				g:RemoveCard(handler)
				return res, not res
			end
end
function s.xyzfilter1(c,e,tp,g)
	if c.rum_limit and not c.rum_limit(g,e,tp,c) then return false end
	return not g:IsExists(aux.NOT(s.IsCanBeXyzMaterial_LessStrict),1,nil,c) and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local g=Duel.Group(s.mfilter1,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,c,e)
	local sg=Duel.Group(s.validxyzfilter,tp,LOCATION_EXTRA,0,nil,c,e,tp)
	if chk==0 then
		return #sg>0 and aux.SelectUnselectGroup(g,e,tp,3,3,s.mcheck1(c,sg),0)
	end
	local tg=aux.SelectUnselectGroup(g,e,tp,3,3,s.mcheck1(c,sg),1,tp,HINTMSG_XMATERIAL)
	Duel.SetTargetCard(tg)
	local opg=tg:Filter(Card.IsInGY,nil)
	if #opg>0 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_FIELD,opg,#opg,tp,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsFaceup() or c:IsImmuneToEffect(e) then return end
	local sg=Duel.Group(s.validxyzfilter,tp,LOCATION_EXTRA,0,nil,c,e,tp)
	if #sg==0 then return end
	local g=Duel.GetTargetCards():Filter(s.targetchk,nil):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	g:AddCard(c)
	if aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_XMATERIAL) then
		Duel.HintMessage(tp,HINTMSG_SPSUMMON)
		local xyz=sg:FilterSelect(tp,s.xyzfilter1,1,1,nil,e,tp,g):GetFirst()
		if xyz then
			local tg=Group.CreateGroup()
			for tc in aux.Next(g) do
				local mg=tc:GetOverlayGroup()
				tg:Merge(mg)
			end
			if #tg>0 then
				Duel.SendtoGrave(tg,REASON_RULE)
			end
			xyz:SetMaterial(g)
			Duel.Overlay(xyz,g)
			if Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
				xyz:CompleteProcedure()
			end
		end
	end
end