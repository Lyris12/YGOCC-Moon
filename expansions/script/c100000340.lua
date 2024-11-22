--[[
Rank-Up-Magic - Silent Succession
Alza-Rango-Magico - Successione Silente
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	--[[Activate 1 of the following effects.
	● Target 1 "Number" Xyz Monster on the field; Special Summon 1 "Number" Xyz Monster from your Extra Deck with a number between "201" and "214" in its name, by using that target as the material
	(This is treated as an Xyz Summon. Transfer its materials to that Summoned monster), and if you do, if that target was on your opponent's field, your opponent can add 1 card from their Deck, GY,
	or banishment to their hand.
	● Target 1 DARK "Number" Xyz Monster you control; Special Summon 1 "Number C" Xyz Monster from your Extra Deck, with the same original number in its name as that target, by using it as material
	(This is treated as an Xyz Summon. Transfer its materials to that Summoned monster), and if you do, if you control "Manaseal Rune Weaving", you can attach any number of "Number" Xyz Monsters
	from your GY and/or banishment to that target.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[During your Main Phase, if this card is in your GY: You can target any number of "Number" Xyz Monsters with different original names in your GY and/or banishment; return those targets to the
	Extra Deck, and if you do, add this card to your hand, then you lose 500 LP for each monster returned to the Extra Deck this way.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetCategory(CATEGORY_TOEXTRA|CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(
		nil,
		nil,
		s.tetg,
		s.teop
	)
	c:RegisterEffect(e2)
end
--E1
function s.filter11(c,e,tp)
	local no=aux.GetXyzNumber(c)
	return no and c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER)
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExistingMatchingCard(s.filter12,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.filter12(c,e,tp,mc)
	if c.rum_limit and not c.rum_limit(mc,e,tp,c) then return false end
	local no=aux.GetXyzNumber(c)
	return no and no>=201 and no<=214 and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.filter21(c,e,tp)
	local no=aux.GetXyzNumber(c)
	return no and c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
		and Duel.IsExists(false,s.filter22,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,no)
end
function s.filter22(c,e,tp,mc,no)
	if c.rum_limit and not c.rum_limit(mc,e,tp,c) then return false end
	return aux.GetXyzNumber(c)==no and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER_C) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSpecialSummoned()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local opt=Duel.GetChainInfo(e:GetChainLink(),CHAININFO_TARGET_PARAM)
		if opt==0 then
			return chkc:IsLocation(LOCATION_MZONE) and s.filter11(chkc,e,tp)
		elseif opt==1 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter21(chkc,e,tp)
		end
	end
	local b1=Duel.IsExists(true,s.filter11,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp)
	local b2=Duel.IsExists(true,s.filter21,tp,LOCATION_MZONE,0,1,nil,e,tp)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,1,b1,b2)
	if not opt then return end
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORIES_SEARCH|CATEGORY_GRAVE_ACTION)
		e:SetCustomCategory(0)
		Duel.Select(HINTMSG_TARGET,true,tp,s.filter11,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
	elseif opt==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetCustomCategory(CATEGORY_ATTACH)
		Duel.Select(HINTMSG_TARGET,true,tp,s.filter21,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		Duel.SetPossibleCustomOperationInfo(0,CATEGORY_ATTACH,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if not opt then return end
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	if opt==0 then
		local no=aux.GetXyzNumber(tc)
		local check=true
		if not no or not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
			or not tc:IsFaceup() or tc:IsImmuneToEffect(e)
			or not tc:IsSetCard(ARCHE_NUMBER) then
			check=false
		end
		if check then
			local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.filter12,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
			local sc=g:GetFirst()
			if sc then
				local oppochk=tc:IsControler(1-tp)
				local mg=tc:GetOverlayGroup()
				if mg:GetCount()~=0 then
					Duel.Overlay(sc,mg)
				end
				sc:SetMaterial(Group.FromCards(tc))
				Duel.Overlay(sc,Group.FromCards(tc))
				if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
					sc:CompleteProcedure()
					if oppochk and Duel.IsExists(false,aux.Necro(Card.IsAbleToHand),tp,0,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,1,nil,1-tp) and Duel.SelectYesNo(1-tp,STRING_ASK_SEARCH) then
						local tg=Duel.Select(HINTMSG_ATOHAND,false,1-tp,aux.Necro(Card.IsAbleToHand),tp,0,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,1,1,nil,1-tp)
						if #tg>0 then
							if tg:GetFirst():IsLocation(LOCATION_GB) then
								Duel.HintSelection(tg)
							end
							Duel.SendtoHand(tg,nil,REASON_EFFECT)
						end
					end
				end
			end
		end

	elseif opt==1 then
		local no=aux.GetXyzNumber(tc)
		local check=true
		if not no or not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
			or not tc:IsFaceup() or tc:IsImmuneToEffect(e) or not tc:IsControler(tp)
			or not tc:IsSetCard(ARCHE_NUMBER) or not tc:IsAttribute(ATTRIBUTE_DARK) then
			check=false
		end
		if check then
			local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.filter12,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,no)
			local sc=g:GetFirst()
			if sc then
				local mg=tc:GetOverlayGroup()
				if mg:GetCount()~=0 then
					Duel.Overlay(sc,mg)
				end
				sc:SetMaterial(Group.FromCards(tc))
				Duel.Overlay(sc,Group.FromCards(tc))
				if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
					sc:CompleteProcedure()
					local ag=Duel.Group(aux.Necro(s.atfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil,sc,e,tp)
					if Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_MANASEAL_RUNE_WEAVING),tp,LOCATION_ONFIELD,0,1,nil)
						and #ag>0 and Duel.SelectYesNo(tp,STRING_ASK_ATTACH) then
						Duel.HintMessage(tp,HINTMSG_ATTACH)
						local atg=ag:Select(tp,1,#ag,nil)
						if #atg>0 then
							Duel.HintSelection(atg)
							Duel.Attach(atg,sc,false,e,REASON_EFFECT,tp)
						end
					end
				end
			end
		end
	end
end
function s.atfilter(c,xyzc,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsCanBeAttachedTo(xyzc,e,tp,REASON_EFFECT)
end

--E2
function s.tgcheck(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER)
end
function s.tefilter(c,e)
	return s.tgcheck(c) and c:IsAbleToExtra() and c:IsCanBeEffectTarget(e)
end
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local g=Duel.Group(s.tefilter,tp,LOCATION_GB,0,c,e)
	if chk==0 then
		return c:IsAbleToHand() and #g>0
	end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,#g,aux.ogdncheckbrk,1,tp,HINTMSG_TOEXTRA)
	Duel.SetTargetCard(tg)
	Duel.SetCardOperationInfo(tg,CATEGORY_TOEXTRA)
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards():Filter(s.tgcheck,nil)
	if #g>0 and Duel.ShuffleIntoDeck(g,nil,LOCATION_EXTRA)>0 then
		local ct=Duel.GetGroupOperatedByThisEffect(e):Filter(Card.IsMonster,nil):FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
		local c=e:GetHandler()
		if c:IsRelateToChain() and Duel.SearchAndCheck(c) and ct>0 then
			Duel.BreakEffect()
			Duel.LoseLP(tp,ct*500)
		end
	end
end