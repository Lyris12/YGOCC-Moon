--[[
Rank-Up-Magic Remnant Force
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--Target 1 "Number" monster you control; Special Summon from your Extra Deck, 1 "Number C" monster with the same number in its name as that target, but at least 1 Rank higher, by using it as the material. (This Special Summon is treated as an Xyz Summon. Transfer its materials to that Summoned monster.) Then, if possible, attach 1 Special Summoned monster your opponent controls to the Summoned monster as material. (Transfer any materials to that target, if any.)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
end

--E1
function s.filter1(c,e,tp)
	local no=aux.GetXyzNumber(c)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsSetCard(ARCHE_NUMBER) and no
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1,no)
end
function s.filter2(c,e,tp,mc,rk,no)
	if c.rum_limit and not c.rum_limit(mc,e,tp,c) then return false end
	local cno=aux.GetXyzNumber(c)
	return c:IsRankAbove(rk) and cno and cno==no and c:IsSetCard(ARCHE_NUMBER_C) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	local no=aux.GetXyzNumber(tc)
	if tc:IsFacedown() or not tc:IsRelateToChain() or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or not tc:IsSetCard(ARCHE_NUMBER) or not no then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,no)
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
			if Duel.IsExists(false,s.ovfilter,tp,0,LOCATION_MZONE,1,nil,tc,e,tp) then
				local oc=Duel.Select(HINTMSG_ATTACH,false,tp,s.ovfilter,tp,0,LOCATION_MZONE,1,1,nil,tc,e,tp):GetFirst()
				if oc then
					Duel.HintSelection(Group.FromCards(oc))
					Duel.BreakEffect()
					Duel.Attach(oc,sc,true,e,REASON_EFFECT,tp)
				end
			end
		end
	end
end
function s.ovfilter(c,xyzc,e,tp)
	return c:IsSpecialSummoned() and c:IsCanBeAttachedTo(xyzc,e,tp,REASON_EFFECT)
end