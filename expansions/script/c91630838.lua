--[[
Rank-Up-Magic Life Force Coalescence
Alza-Rango-Magico Coalescenza della Forza Vitale
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Target 1 "Number" Xyz Monster you control, and reveal 1 "Number C" Xyz Monster in your Extra Deck with the same Attribute as that target, but with a higher Rank;
	banish Zombie monsters from your GY, equal to the difference between the Rank of that target and the revealed monster (min. 1), and if you do,
	Special Summon that revealed monster by using that target as the material (This is treated as an Xyz Summon. Transfer its materials to that target).
	Then, if you have "Lich-Lord's Phylactery" in your GY, and you also had "Lich-Lord's Phylactery" in your GY at activation,
	attach all cards that were banished by this effect to that monster as materials.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
end
function s.filter1(c,e,tp,g)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1,c:GetAttribute(),g)
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
function s.filter2(c,e,tp,mc,rk,attr,g)
	if not (c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER_C) and c:IsAttribute(attr) and c:IsRankAbove(rk) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)) then
		return false
	end
	local cg=g:Clone()
	cg:AddCard(mc)
	return aux.SelectUnselectGroup(cg,e,tp,2,#cg,s.ChkfMMZ(c,mc,c:GetRank()-rk),0)
end
function s.rmfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemove()
end
function s.ChkfMMZ(c,mc,ct)
	return	function(sg,e,tp,mg)
				return ct==#sg and sg:IsContains(mc) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0, #sg>ct
			end
end
function s.ChkfMMZ2(c)
	return	function(sg,e,tp,mg)
				return Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
			end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.Group(s.rmfilter,tp,LOCATION_GRAVE,0,nil)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp,g) end
	if chk==0 then
		return #g>0 and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp,g)
	end
	local label=aux.PhylacteryCheck(tp) and 1 or 0
	Duel.SetTargetParam(label)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp,g):GetFirst()
	if tc then
		local sg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,tc:GetAttribute(),g)
		Duel.ConfirmCards(1-tp,sg)
		local tg=sg:Clone()
		tg:AddCard(tc)
		Duel.SetTargetCard(tg)
		e:SetLabelObject(sg:GetFirst())
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
		Duel.SetCardOperationInfo(sg,CATEGORY_SPECIAL_SUMMON)
	end
end
function s.checktg(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsControler(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local targets=Duel.GetTargetCards()
	if #targets~=2 then return end
	local tc,xyzc=targets:GetFirst(),targets:GetNext()
	if e:GetLabelObject()~=xyzc then
		tc,xyzc=xyzc,tc
	end
	if not tc:IsRelateToChain() or not s.checktg(tc,tp) or not xyzc:IsRelateToChain() or not xyzc:IsType(TYPE_XYZ) then return end
	local ct=xyzc:GetRank()-tc:GetRank()
	if ct<=0 then return end
	local g=Duel.Group(s.rmfilter,tp,LOCATION_GRAVE,0,nil)
	if #g<ct then return end
	local rg
	if Duel.GetLocationCountFromEx(tp,tp,tc,xyzc)>0 then
		rg=g:Select(tp,ct,ct,nil)
	else
		rg=aux.SelectUnselectGroup(g,e,tp,ct,ct,s.ChkfMMZ2(c),1,tp,HINTMSG_REMOVE)
	end
	if #rg<=0 then return end
	Duel.HintSelection(rg)
	if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(Card.IsBanished,nil):Filter(aux.BecauseOfThisEffect,nil,e)
		for oc in aux.Next(og) do
			oc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
		end
		if not tc:IsRelateToChain() or not s.checktg(tc,tp) or tc:IsImmuneToEffect(e) or not xyzc:IsRelateToChain() or not xyzc:IsType(TYPE_XYZ) then return end
		if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) or Duel.GetLocationCountFromEx(tp,tp,tc,xyzc)<=0 then return end
		local mg=tc:GetOverlayGroup()
		if #mg~=0 then
			Duel.Overlay(xyzc,mg)
		end
		xyzc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(xyzc,Group.FromCards(tc))
		if Duel.SpecialSummon(xyzc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			xyzc:CompleteProcedure()
			og=og:Filter(Card.HasFlagEffect,nil,id)
			if aux.PhylacteryCheck(tp) and Duel.GetTargetParam()==1 and #og>0 then
				Duel.BreakEffect()
				Duel.Attach(og,xyzc)
			end
		end
	end
end