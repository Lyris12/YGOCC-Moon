--Stellar Markshall
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--fusion summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(cid.spcost)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
	--pop and ss
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id+100)
	e3:SetLabel(101)
	e3:SetCondition(cid.sscon)
	e3:SetCost(cid.sscost)
	e3:SetTarget(cid.sstg)
	e3:SetOperation(cid.ssop)
	c:RegisterEffect(e3)
	--quick activation
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf2,0xf80,0x7a4))
	e4:SetTargetRange(LOCATION_SZONE,0)
	c:RegisterEffect(e4)
	--activate cost
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_ACTIVATE_COST)
	e5:SetRange(LOCATION_PZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,0)
	e5:SetTarget(cid.actarget)
	e5:SetCost(cid.costchk)
	e5:SetOperation(cid.costop)
	c:RegisterEffect(e5)
	-- local e6=e5:Clone()
	-- e6:SetTargetRange(0,1)
	-- c:RegisterEffect(e6)
	if not cid.global_check then
		cid.global_check=true
		--check turn set
		local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_SSET)
		e8:SetOperation(cid.ckop)
		Duel.RegisterEffect(e8,0)
		--chainlimit
		local e9=Effect.CreateEffect(c)
		e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e9:SetCode(EVENT_CHAINING)
		e9:SetOperation(cid.actop)
		Duel.RegisterEffect(e9,0)
	end
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
end
function cid.counterfilter(c)
	return c:IsSetCard(0x7a4) or c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM)
end

--FUSION SUMMON
function cid.filter0(c,e)
	return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
		and (c:IsLocation(LOCATION_PZONE) or (c:IsFaceup() and c:GetFlagEffect(EFFECT_PANDEMONIUM)>0))
end
function cid.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function cid.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsType(TYPE_PANDEMONIUM) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp)
		mg1:Merge(Duel.GetMatchingGroup(cid.filter0,tp,LOCATION_PZONE+LOCATION_SZONE,LOCATION_PZONE+LOCATION_SZONE,nil,e))
		local res=Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(cid.filter1,nil,e)
	mg1:Merge(Duel.GetMatchingGroup(cid.filter0,tp,LOCATION_PZONE+LOCATION_SZONE,LOCATION_PZONE+LOCATION_SZONE,nil,e))
	local sg1=Duel.GetMatchingGroup(cid.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(cid.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end

--SPSUMMON
function cid.rmfilter1(c)
	return c:IsType(TYPE_TRAP+TYPE_PANDEMONIUM) and c:IsAbleToRemoveAsCost() and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
end
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(cid.rmfilter1,tp,LOCATION_GRAVE+LOCATION_EXTRA,LOCATION_GRAVE,1,nil)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.rmfilter1,tp,LOCATION_GRAVE+LOCATION_EXTRA,LOCATION_GRAVE,1,1,nil)
	if Duel.Remove(g,POS_FACEUP,REASON_COST)~=0 and g:GetFirst():IsLocation(LOCATION_REMOVED) then
		Duel.SetTargetCard(g)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,1)
		e1:SetTarget(cid.aclimit)
		e1:SetLabel(tc:GetOriginalCodeRule())
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function cid.aclimit(e,re,tp)
	return re:GetHandler():IsOriginalCodeRule(e:GetLabel())
end

--POP AND SS
function cid.sscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function cid.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.splimit)
	Duel.RegisterEffect(e1,tp)
end
function cid.splimit(e,c)
	return not cid.counterfilter(c)
end
function cid.dryfilter(c,e,tp)
	return (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x7a4) and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetOriginalAttribute())
end
function cid.spfilter(c,e,tp,attr)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x7a4) and c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM)
		and bit.band(c:GetOriginalAttribute(),attr)==0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.dryfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cid.ssop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,cid.dryfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	if g1:GetCount()>0 then
		Duel.HintSelection(g1)
		if Duel.Destroy(g1,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g2=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,g1:GetFirst():GetOriginalAttribute())
			if g2:GetCount()>0 then
				Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

--activate cost
function cid.actarget(e,te,tp)
	return te:GetHandler():IsFacedown() and te:GetHandler():IsType(TYPE_TRAP) and te:GetHandler():IsSetCard(0xf2,0xf80,0x7a4) and te:GetHandler():GetFlagEffect(id)>0
end
function cid.costchk(e,te_or_c,tp)
	return Duel.CheckLPCost(tp,1000) and Duel.GetFlagEffect(tp,id)<=0
end
function cid.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.PayLPCost(tp,1000)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
--check turn set
function cid.ckop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,EFFECT_FLAG_SET_AVAILABLE,1)
	end
end
--chainlimit
function cid.actop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep~=tp then
		Duel.SetChainLimit(cid.limit(e:GetHandler()))
	end
end
function cid.limit(c)
	return	function (e,lp,tp)
				return not (tp==lp and e:GetHandler()==c and e:GetLabel()==101)
			end
end