--[[
Rank-Up-Magic - Art of War
Alza-Rango-Magico - Arte della Guerra
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
end

--E1
function s.mfilter1(c,e)
	return c:IsFaceupEx() and c:IsMonster() and c:IsCanBeEffectTarget(e) and c:IsSetCard(ARCHE_INVERNAL) and c:HasOriginalLevel()
end
function s.mcheck1(check)
	return	function(g,e,tp,mg,c)
				local lvchk=g:GetClassCount(Card.GetOriginalLevel)==1 and aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_XMATERIAL)
				if not lvchk then
					return false, false
				end
				if #g<3 then return true end
				local res=Duel.IsExists(false,s.xyzfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,g,g:GetFirst():GetOriginalLevel(),check)
				return res, not res
			end
end
function s.xyzfilter1(c,e,tp,g,lv,check)
	if c.rum_limit and not c.rum_limit(g,e,tp,c) then return false end
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRankBelow(lv) and not g:IsExists(aux.NOT(Card.IsCanBeXyzMaterial),1,nil,c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
		and (not check or Duel.IsExists(false,s.xyzfilter2,tp,LOCATION_EXTRA,0,1,c,e,tp,c,aux.GetXyzNumber(c),check))
end
function s.mfilter2(c,e,tp)
	local no=aux.GetXyzNumber(c)
	return no and c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExists(false,s.xyzfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,no,false)
end
function s.xyzfilter2(c,e,tp,mc,no,check)
	if c.rum_limit and not c.rum_limit(mc,e,tp,c) then return false end
	if check and not no then return false end
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER_C) and aux.GetXyzNumber(c)==no and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and (check or Duel.GetLocationCountFromEx(tp,tp,mc,c)>0)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.Group(s.mfilter1,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,e)
	local b1=aux.SelectUnselectGroup(g,e,tp,3,5,s.mcheck1(false),0)
	local b2=Duel.IsExists(false,s.mfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp)
	if chk==0 then
		return b1 or b2
	end
	local both=Duel.IsExists(false,Card.IsSpecialSummoned,tp,0,LOCATION_MZONE,2,nil,LOCATION_EXTRA) and Duel.IsPlayerCanSpecialSummonCount(tp,2) and ((b1 and b2) or aux.SelectUnselectGroup(g,e,tp,3,5,s.mcheck1(true),0))
	local opt=aux.Option(tp,id,1,b1,b2,both)+1
	local check=opt==3
	e:SetProperty(0)
	if opt&1==1 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local tg=aux.SelectUnselectGroup(g,e,tp,3,5,s.mcheck1(check),1,tp,HINTMSG_XMATERIAL,s.mcheck1)
		Duel.SetTargetCard(tg)
		local opg=tg:Filter(Card.IsInGY,nil)
		if #opg>0 then
			Duel.SetOperationInfo(0,CATEGORY_LEAVE_FIELD,opg,#opg,tp,0)
		end
	end
	Duel.SetTargetParam(opt)
	local ct=check and 2 or 1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	local b2=Duel.IsExists(false,s.mfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp)
	local check=opt==3
	local brk=false
	if opt&1==1 then
		local g=Duel.GetTargetCards():Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
		if #g>0 and aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_XMATERIAL) then
			local rescheck=false
			if check and not b2 and Duel.IsExists(false,s.xyzfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,g,g:GetFirst():GetOriginalLevel(),true) then
				rescheck=true
			end
			
			local xyz=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.xyzfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g,g:GetFirst():GetOriginalLevel(),rescheck):GetFirst()
			if xyz then
				for tc in aux.Next(g) do
					local mg=tc:GetOverlayGroup()
					if #mg~=0 then
						Duel.Overlay(xyz,mg)
					end
				end
				xyz:SetMaterial(g)
				Duel.Overlay(xyz,g)
				if Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
					xyz:CompleteProcedure()
					brk=true
				end
			end
		end
	end
	if opt&2==2 then
		local g=Duel.Select(HINTMSG_XMATERIAL,false,tp,s.mfilter2,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		if #g>0 then
			local tc=g:GetFirst()
			local xyz=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.xyzfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,aux.GetXyzNumber(tc),false):GetFirst()
			if xyz then
				if brk then Duel.BreakEffect() end
				local mg=tc:GetOverlayGroup()
				if #mg~=0 then
					Duel.Overlay(xyz,mg)
				end
				xyz:SetMaterial(g)
				Duel.Overlay(xyz,g)
				if Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
					xyz:CompleteProcedure()
				end
			end
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(id,4)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTargetRange(1,0)
	Duel.RegisterEffect(e1,tp)
end