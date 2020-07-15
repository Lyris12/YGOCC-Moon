--created by Walrus, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	aux.CannotBeEDMaterial(c,nil,LOCATION_MZONE)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1056)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetTarget(cid.ftg)
	e1:SetOperation(cid.fop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(1164)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetTarget(cid.stg)
	e2:SetOperation(cid.sop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re and re:GetHandler():IsSetCard(0xc97) and e:GetHandler():IsReason(REASON_EFFECT) end)
	e3:SetCost(cid.cost)
	e3:SetTarget(cid.tg)
	e3:SetOperation(cid.op)
	c:RegisterEffect(e3)
end
function cid.filter0(c)
	return c:IsLocation(LOCATION_HAND) and c:IsAbleToRemove()
end
function cid.filter1(c,e)
	return c:IsLocation(LOCATION_HAND) and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function cid.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x6c97) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,e:GetHandler(),chkf)
end
function cid.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
function cid.ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(cid.filter0,nil)
		local mg2=Duel.GetMatchingGroup(cid.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		local res=Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function cid.fop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(cid.filter1,nil,e)
	local mg2=Duel.GetMatchingGroup(cid.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	local sg1=Duel.GetMatchingGroup(cid.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(cid.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,e:GetHandler(),chkf)
			tc:SetMaterial(mat1)
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2,SUMMON_TYPE_FUSION)
		end
		tc:CompleteProcedure()
	end
end
function cid.cfilter(c)
	if not c:IsSetCard(0xc97) or not c:IsType(TYPE_MONSTER) then return false end
	if c:IsLocation(LOCATION_HAND) then return c:IsDiscardable(REASON_EFFECT)
	else return c:IsAbleToRemove() end
end
function cid.spfilter(c,e,tp,t)
	if not c:IsSetCard(0x6c97) then return false end
	if not t then t={
		[TYPE_SYNCHRO]=SUMMON_TYPE_SYNCHRO,
		[TYPE_BIGBANG]=SUMMON_TYPE_BIGBANG,
		[TYPE_EVOLUTE]=SUMMON_TYPE_EVOLUTE,
	} end
	local st=t[c:GetType()&TYPE_EXTRA]
	return st~=nil and c:IsCanBeSpecialSummoned(e,st,tp,false,false)
end
function cid.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable(REASON_EFFECT) and Duel.GetLocationCountFromEx(tp)>0
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cid.sop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(cid.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,c)
	if not c:IsRelateToEffect(e) or #mg<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local g=mg:Select(tp,2,2,nil)+c
	local t={
		[TYPE_SYNCHRO]=SUMMON_TYPE_SYNCHRO,
		[TYPE_BIGBANG]=SUMMON_TYPE_BIGBANG,
		[TYPE_EVOLUTE]=SUMMON_TYPE_EVOLUTE,
	}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,t):GetFirst()
	if sc then
		sc:SetMaterial(g)
		Duel.Remove(g:Filter(Card.IsLocation,nil,LOCATION_GRAVE),POS_FACEUP,REASON_EFFECT)
		Duel.SendtoGrave(g:Filter(Card.IsLocation,nil,LOCATION_HAND),REASON_EFFECT+REASON_DISCARD)
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,t[sc:GetType()&TYPE_EXTRA],tp,tp,false,false,POS_FACEUP)
	end
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Damage(tp,1000,REASON_COST)
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
