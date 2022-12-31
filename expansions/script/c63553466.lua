--Maresciallo Universale
--Script by XGlitchy30
function c63553466.initial_effect(c)
	--fusion summon
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,c63553466.matfilter,3,false)
	aux.AddContactFusionProcedure(c,Card.IsReleasable,LOCATION_MZONE,0,Duel.Release,REASON_COST+REASON_MATERIAL)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c63553466.splimit)
	c:RegisterEffect(e1)
	--special summon rule
	-- local e2=Effect.CreateEffect(c)
	-- e2:SetType(EFFECT_TYPE_FIELD)
	-- e2:SetCode(EFFECT_SPSUMMON_PROC)
	-- e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	-- e2:SetRange(LOCATION_EXTRA)
	-- e2:SetCondition(c63553466.spcon)
	-- e2:SetOperation(c63553466.spop)
	-- c:RegisterEffect(e2)
	--cannot trigger/ flip summon limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_SZONE)
	e3:SetTarget(c63553466.limittg)
	c:RegisterEffect(e3)
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_FIELD)
	e3x:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	e3x:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3x:SetRange(LOCATION_MZONE)
	e3x:SetTargetRange(0,LOCATION_MZONE)
	e3x:SetTarget(c63553466.limittg)
	c:RegisterEffect(e3x)
	--quick activation
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	c:RegisterEffect(e4)
	--activate cost
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_ACTIVATE_COST)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,0)
	e5:SetTarget(c63553466.actarget)
	e5:SetCost(c63553466.costchk)
	e5:SetOperation(c63553466.costop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetTargetRange(0,1)
	c:RegisterEffect(e6)
	--accumulate
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(0x10000000+63553466)
	e7:SetRange(LOCATION_MZONE)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetTargetRange(1,1)
	c:RegisterEffect(e7)
	--gain lp
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e9:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e9:SetCode(EVENT_PHASE+PHASE_END)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCountLimit(1)
	e9:SetOperation(c63553466.lpop)
	c:RegisterEffect(e9)
	--cost payment check
	if not c63553466.global_check then
		c63553466.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PAY_LPCOST)
		ge1:SetOperation(c63553466.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c63553466.clear)
		Duel.RegisterEffect(ge2,0)
		--check turn set
		local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_SSET)
		e8:SetOperation(c63553466.ckop)
		Duel.RegisterEffect(e8,0)
	end
end
c63553466.lpcost1=0
c63553466.lpcost2=0
--cost payment check
function c63553466.checkop(e,tp,eg,ep,ev,re,r,rp)
	if ep==Duel.GetTurnPlayer() then
		local val=math.ceil(ev)
		c63553466.lpcost1=c63553466.lpcost1+val
	else
		local val=math.ceil(ev)
		c63553466.lpcost2=c63553466.lpcost2+val
	end
end
function c63553466.clear(e,tp,eg,ep,ev,re,r,rp)
	c63553466.lpcost1=0
	c63553466.lpcost2=0
end
--filters
function c63553466.matfilter(c)
	return (c:IsType(TYPE_PENDULUM) or c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM) and c:IsCanBeFusionMaterial()
end
function c63553466.fselect(c,tp,mg,sg)
	sg:AddCard(c)
	local res=false
	if sg:GetCount()<3 then
		res=mg:IsExists(c63553466.fselect,1,sg,tp,mg,sg)
	else
		res=Duel.GetLocationCountFromEx(tp,tp,sg)>0
	end
	sg:RemoveCard(c)
	return res
end
-- function c63553466.spfilter(c,fc)
	-- return c63553466.matfilter(c) and c:IsCanBeFusionMaterial(fc)
-- end
-- function c63553466.spfilter1(c,tp,g)
	-- return g:IsExists(c63553466.spfilter2,1,c,tp,c)
-- end
-- function c63553466.spfilter2(c,tp,mc)
	-- return Duel.GetLocationCountFromEx(tp,tp,Group.FromCards(c,mc))>0
-- end
--spsummon condition and rule
function c63553466.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function c63553466.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetReleaseGroup(tp):Filter(c63553466.matfilter,nil)
	local sg=Group.CreateGroup()
	return g:IsExists(c63553466.fselect,1,nil,tp,g,sg)
end
function c63553466.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetReleaseGroup(tp):Filter(c63553466.matfilter,nil)
	local sg=Group.CreateGroup()
	while sg:GetCount()<3 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g1=g:FilterSelect(tp,c63553466.fselect,1,1,sg,tp,g,sg)
		sg:Merge(g1)
	end
	local cg=sg:Filter(Card.IsFacedown,nil)
	if cg:GetCount()>0 then
		Duel.ConfirmCards(1-tp,cg)
	end
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_COST+REASON_FUSION+REASON_MATERIAL)
end
--cannot trigger / flip summon limit
function c63553466.limittg(e,c)
	return c:IsFacedown() and e:GetHandler():GetColumnGroup():IsContains(c)
end
--activate cost
function c63553466.actarget(e,te,tp)
	return te:GetHandler():IsFacedown() and te:GetHandler():GetFlagEffect(63553416)>0
end
function c63553466.costchk(e,te_or_c,tp)
	local ct=Duel.GetFlagEffect(tp,63553466)
	return Duel.CheckLPCost(tp,ct*1000)
end
function c63553466.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,63553466)
	Duel.PayLPCost(tp,1000)
end
--check turn set
function c63553466.ckop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		tc:RegisterFlagEffect(63553416,RESET_PHASE+PHASE_END,EFFECT_FLAG_SET_AVAILABLE,1)
	end
end
--gain lp
function c63553466.lpop(e,tp,eg,ep,ev,re,r,rp)
	local lp1=0
	local lp2=0
	if Duel.GetTurnPlayer()==tp then
		lp1=c63553466.lpcost1
		lp2=c63553466.lpcost2
	else
		lp2=c63553466.lpcost1
		lp1=c63553466.lpcost2
	end
	Duel.Recover(tp,lp2,REASON_EFFECT)
	Duel.Recover(1-tp,lp1,REASON_EFFECT)
end