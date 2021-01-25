--A Skydian of Dawn, Frejia
--Scripted by Glitchy, updated by Zerry
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--search
		local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11111005,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(cid.descon)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCost(cid.descost)
	e1:SetTarget(cid.destg)
	e1:SetOperation(cid.desop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
end
--SEARCH
--filters
function cid.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x223) and c:IsAbleToHand()
end
---------
function cid.rmfil(c)
	return c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function cid.descon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x223)
end
function cid.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.rmfil,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.rmfil,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
--SPECIAL SUMMON
--filters
function cid.immune(c,e)
	return not c:IsImmuneToEffect(e)
end
function cid.exfilter(c,mg)
	if not c:IsType(TYPE_MONSTER) or not c:IsSetCard(0x223) or (c:IsType(TYPE_PENDULUM) and c:IsFaceup()) then return false end
	return c:IsSynchroSummonable(nil,mg) or c:IsXyzSummonable(nil,mg) or c:IsLinkSummonable(nil)
end
function cid.fusfilter(c,e,tp,m,f,chkf)
	if not c:IsType(TYPE_MONSTER) or not c:IsSetCard(0x223) or (c:IsType(TYPE_PENDULUM) and c:IsFaceup()) then return false end
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
---------
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local mg1=Duel.GetFusionMaterial(tp):Filter(aux.AND(Card.IsOnField,Card.IsFaceup),nil)
		local res=Duel.IsExistingMatchingCard(cid.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(cid.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return Duel.IsExistingMatchingCard(cid.exfilter,tp,LOCATION_EXTRA,0,1,nil,mg) or res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf,checksg2=tp,false
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.AND(Card.IsOnField,Card.IsFaceup),nil):Filter(cid.immune,nil,e)
	local sg1=Duel.GetMatchingGroup(cid.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c12450071.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	local g=Duel.GetMatchingGroup(cid.exfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if #sg1>0 then
		g:Merge(sg1)
	elseif (sg2~=nil and sg2:GetCount()>0) then
		g:Merge(sg2)
		checksg2=true
	end
	if #g>0 then
		local sg=sg1:Clone()
		if checksg2 then sg:Merge(sg2) end
		local opt,ct=0,0
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg0=g:Select(tp,1,1,nil):GetFirst()
		if sg0:IsType(TYPE_FUSION) then opt=opt|TYPE_FUSION ct=ct+1 end
		if sg0:IsSynchroSummonable(nil,mg) then opt=opt|TYPE_SYNCHRO ct=ct+1 end
		if sg0:IsXyzSummonable(nil,mg) then opt=opt|TYPE_XYZ ct=ct+1 end
		if sg0:IsLinkSummonable(nil) then opt=opt|TYPE_LINK ct=ct+1 end
		if ct>1 then
			local ok=true
			while ok do
				if opt&TYPE_FUSION>0 then
					if Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
						opt=TYPE_FUSION
						ok=false
						break
					end
				end
				if opt&TYPE_SYNCHRO>0 then
					if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
						opt=TYPE_SYNCHRO
						ok=false
						break
					end
				end
				if opt&TYPE_XYZ>0 then
					if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
						opt=TYPE_XYZ
						ok=false
						break
					end
				end
				if opt&TYPE_LINK>0 then
					if Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
						opt=TYPE_LINK
						ok=false
						break
					end
				end
			end
		end
		if opt&TYPE_FUSION>0 then
			if sg1:IsContains(sg0) and (sg2==nil or not sg2:IsContains(sg0) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				local mat1=Duel.SelectFusionMaterial(tp,sg0,mg1,nil,chkf)
				sg0:SetMaterial(mat1)
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				Duel.SpecialSummon(sg0,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				local mat2=Duel.SelectFusionMaterial(tp,sg0,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,sg0,mat2)
			end
			sg0:CompleteProcedure()
		elseif opt&TYPE_SYNCHRO>0 then
			Duel.SynchroSummon(tp,sg0,nil,mg)
		elseif opt&TYPE_XYZ>0 then
			Duel.XyzSummon(tp,sg0,nil,mg)
		elseif opt&TYPE_LINK>0 then
			Duel.LinkSummon(tp,sg0,nil)
		else
			return
		end
	end
end