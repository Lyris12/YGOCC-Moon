--[[
Rank-Up-Magic - Sceluspecter Prophecy
Alza-Rango-Magico - Profezia Scelleraspettro
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
end
--E1
function s.filter11(c,e,tp)
	local no=aux.GetXyzNumber(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and not c:IsSetCard(ARCHE_NUMBER_C) and no
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExistingMatchingCard(s.filter12,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1,no)
end
function s.filter12(c,e,tp,mc,rk,no)
	if c.rum_limit and not c.rum_limit(mc,e,tp,c) then return false end
	return c:IsRankAbove(rk) and c:IsSetCard(ARCHE_NUMBER_C) and aux.GetXyzNumber(c)==no and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.filter21(c,tp,sg)
	if not (c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER)) then return false end
	local g=sg:Filter(aux.NOT(Card.IsCode),nil,c:GetCode())
	local ct=g:GetClassCount(Card.GetCode)
	return ct>0 and Duel.IsExists(false,s.filter22,tp,LOCATION_EXTRA,0,math.floor(ct/2),nil)
end
function s.filter22(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsCanOverlay()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSpecialSummoned()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local sg=Duel.Group(s.cfilter,tp,0,LOCATION_MZONE,nil)
	if chkc then
		local opt=Duel.GetChainInfo(e:GetChainLink(),CHAININFO_TARGET_PARAM)
		if opt==0 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter11(chkc,e,tp)
		elseif opt==1 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter21(chkc,tp,sg)
		end
	end
	local b1=Duel.IsExists(true,s.filter11,tp,LOCATION_MZONE,0,1,nil,e,tp)
	local b2=#sg>1 and Duel.IsExists(true,s.filter21,tp,LOCATION_MZONE,0,1,nil,tp,sg)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,1,b1,b2)
	if not opt then return end
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_REMOVE)
		local g=Duel.Select(HINTMSG_TARGET,true,tp,s.filter11,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	elseif opt==1 then
		e:SetCategory(0)
		Duel.Select(HINTMSG_TARGET,true,tp,s.filter21,tp,LOCATION_MZONE,0,1,1,nil,tp,sg)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if not opt then return end
	local tc=Duel.GetFirstTarget()
	if opt==0 then
		local no=aux.GetXyzNumber(tc)
		local check=true
		if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
			or not tc:IsFaceup() or not tc:IsRelateToChain() or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or not no
			or not (tc:IsSetCard(ARCHE_NUMBER) and not tc:IsSetCard(ARCHE_NUMBER_C)) then
			check=false
		end
		if check then
			local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.filter12,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,no)
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
				end
			end
		end
		aux.ApplyEffectImmediatelyAfterResolution(s.rmop,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
	elseif opt==1 then
		if not tc:IsRelateToChain() or not tc:IsFaceup() or tc:IsControler(1-tp) or not tc:IsType(TYPE_XYZ) or not tc:IsSetCard(ARCHE_NUMBER) then return end
		local sg=Duel.Group(s.cfilter,tp,0,LOCATION_MZONE,nil):Filter(aux.NOT(Card.IsCode),nil,tc:GetCode())
		local ct=math.floor(sg:GetClassCount(Card.GetCode)/2)
		if ct>0 then
			local og=Duel.Group(s.filter22,tp,LOCATION_EXTRA,0,nil)
			if #og>=ct then
				Duel.HintMessage(tp,HINTMSG_ATTACH)
				local og2=og:Select(tp,ct,ct,nil)
				Duel.ConfirmCards(1-tp,og2)
				Duel.Attach(og2,tc,false,e,REASON_EFFECT,tp)
			end
		end
	end
end
function s.rmfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsAbleToRemove()
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp,_e)
	local g=Duel.Group(aux.Necro(s.rmfilter),tp,LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,STRING_ASK_BANISH) then
		Duel.HintMessage(tp,HINTMSG_REMOVE)
		local rg=g:Select(tp,1,1,nil)
		Duel.HintSelection(rg)
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end