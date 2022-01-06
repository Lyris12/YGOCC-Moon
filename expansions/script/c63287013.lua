--Card Hunter of "Set" - The Lawnmower
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	c:SetUniqueOnField(1,1,cid.uqfilter,LOCATION_MZONE)
	--cannot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	local e0x=e0:Clone()
	e0x:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	e0x:SetValue(1)
	c:RegisterEffect(e0x)
	--nsummon proc
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(cid.ttcon)
	e1:SetOperation(cid.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(cid.setcon)
	c:RegisterEffect(e2)
	--summon cost
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SUMMON_COST)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCost(cid.smcost)
	e3:SetOperation(cid.smop)
	c:RegisterEffect(e3)
	--remove
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCost(cid.cardhuntercost)
	e4:SetTarget(cid.rmtg)
	e4:SetOperation(cid.rmop)
	c:RegisterEffect(e4)
	--cannot set
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_CANNOT_MSET)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	c:RegisterEffect(e5)
	local e5x=e5:Clone()
	e5x:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e5x)
	local e5y=Effect.CreateEffect(c)
	e5y:SetType(EFFECT_TYPE_FIELD)
	e5y:SetCode(EFFECT_CANNOT_TURN_SET)
	e5y:SetRange(LOCATION_MZONE)
	e5y:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	c:RegisterEffect(e5y)
	--handtrap effect
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_MSET)
	e6:SetRange(LOCATION_HAND)
	e6:SetCountLimit(1)
	e6:SetCondition(cid.htcon)
	e6:SetCost(cid.htcost)
	e6:SetTarget(cid.httg)
	e6:SetOperation(cid.htop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_SSET)
	c:RegisterEffect(e7)
	local e8=e6:Clone()
	e8:SetCode(EVENT_CHANGE_POS)
	c:RegisterEffect(e8)
	Duel.AddCustomActivityCounter(id,ACTIVITY_NORMALSUMMON,cid.counterfilter)
end
--Generic Filters
function cid.counterfilter(c)
	return not c:IsSetCard(0xca4d) or c:IsCode(id)
end
function cid.uqfilter(c)
	return c:IsSetCard(0xca4d)
end
--NSUMMON PROC
--filters
function cid.otfilter(c)
	return c:IsFacedown() and c:IsReleasable()
end
function cid.exfilter(c,g,sc)
	if not c:IsFacedown() or not c:IsReleasable() or g:IsContains(c) or c:IsHasEffect(EFFECT_EXTRA_RELEASE) then return false end
	local sume={c:IsHasEffect(EFFECT_UNRELEASABLE_SUM)}
	for _,te in ipairs(sume) do
		if type(te:GetValue())=='function' then
			if te:GetValue()(te,sc) then 
				return false 
			end
		else 
			return false 
		end
	end
	return true
end
function cid.val(c,sc,ma)
	local eff3={c:IsHasEffect(EFFECT_TRIPLE_TRIBUTE)}
	if ma>=3 then
		for _,te in ipairs(eff3) do
			if type(te:GetValue())~='function' or te:GetValue()(te,sc) then return 0x30001 end
		end
	end
	local eff2={c:IsHasEffect(EFFECT_DOUBLE_TRIBUTE)}
	for _,te in ipairs(eff2) do
		if type(te:GetValue())~='function' or te:GetValue()(te,sc) then return 0x20001 end
	end
	return 1
end
function cid.req(c)
	return c:IsFacedown() and c:IsLocation(LOCATION_SZONE)
end
function cid.unreq(c,tp)
	return c:IsControler(1-tp) and c:IsFacedown() and not c:IsHasEffect(EFFECT_EXTRA_RELEASE)
end
function cid.rescon(sg,e,tp,mg)
	local c=e:GetHandler()
	if not cid.ChkfMMZ(1)(sg,e,tp,mg) then 
		return false 
	end
	local ct=#sg
	return sg:CheckWithSumEqual(cid.val,5,ct,ct,c,5)
end
-----------
function cid.ttcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetTributeGroup(c):Filter(Card.IsFacedown,nil)
	local exg=Duel.GetMatchingGroup(cid.otfilter,tp,LOCATION_SZONE,0,nil)
	g:Merge(exg)
	local opg=Duel.GetMatchingGroup(cid.exfilter,tp,0,LOCATION_MZONE+LOCATION_SZONE,nil,g,c)
	g:Merge(opg)
	return minc<=5 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-5 and cid.SelectUnselectGroup(g,e,tp,1,5,cid.rescon,0)
end
function cid.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetTributeGroup(c):Filter(Card.IsFacedown,nil)
	local exg=Duel.GetMatchingGroup(cid.otfilter,tp,LOCATION_SZONE,0,nil)
	g:Merge(exg)
	local opg=Duel.GetMatchingGroup(cid.exfilter,tp,0,LOCATION_MZONE+LOCATION_SZONE,nil,g,c)
	g:Merge(opg)
	local sg=cid.SelectUnselectGroup(g,e,tp,1,5,cid.rescon,1,tp,HINTMSG_RELEASE,cid.rescon)
	local remc=sg:Filter(cid.unreq,nil,tp):GetFirst()
	if remc then
		local rele={remc:IsHasEffect(EFFECT_EXTRA_RELEASE_SUM)}
		for _,rdelete in ipairs(rele) do
			rdelete:Reset()
		end
	end
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
function cid.setcon(e,c,minc)
	if not c then return true end
	return false
end
--SUMMON COST
function cid.smcost(e,c,tp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_NORMALSUMMON)==0 and (Duel.GetFlagEffect(tp,63287013)<=0 or Duel.GetFlagEffectLabel(tp,63287013)==id)
end
function cid.smop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.nslimit)
	Duel.RegisterEffect(e1,tp)
end
function cid.nslimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsSetCard(0xca4d) and not c:IsCode(id)
end
--REMOVE
--filters
function cid.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
---------
function cid.cardhuntercost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,63287013)<=0 or Duel.GetFlagEffectLabel(tp,63287013)==id end
	Duel.RegisterFlagEffect(tp,63287013,RESET_PHASE+PHASE_END,0,1)
	Duel.SetFlagEffectLabel(tp,63287013,id)
end
function cid.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(cid.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
function cid.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cid.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end
--HANDTRAP EFFECT
--filters
function cid.sfilter(c,e)
	return c:IsFacedown() and (not e or c:IsRelateToEffect(e))
end
---------
function cid.htcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function cid.htcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function cid.httg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=eg:Filter(cid.sfilter,nil)
		return #g==1 
	end
	local g=eg:Filter(cid.sfilter,nil)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function cid.htop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(cid.sfilter,nil,e)
	if #g==1 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_FORBIDDEN)
		e1:SetTargetRange(0x7f,0x7f)
		e1:SetTarget(cid.bantg)
		e1:SetLabel(g:GetFirst():GetCode())
		Duel.RegisterEffect(e1,tp)
	end
end
function cid.bantg(e,c)
	local code1,code2=c:GetOriginalCodeRule()
	local fcode=e:GetLabel()
	return code1==fcode or code2==fcode
end


--SelectUnselect Loop auxiliaries, original from Percy
function cid.SelectUnselectLoop(c,sg,mg,e,tp,minc,maxc,rescon)
	local res
	if sg:GetCount()>=maxc then return false end
	sg:AddCard(c)
	if sg:GetCount()<minc then
		res=mg:IsExists(cid.SelectUnselectLoop,1,sg,sg,mg,e,tp,minc,maxc,rescon)
	elseif sg:GetCount()<maxc then
		res=(not rescon or rescon(sg,e,tp,mg)) or mg:IsExists(cid.SelectUnselectLoop,1,sg,sg,mg,e,tp,minc,maxc,rescon)
	else
		res=(not rescon or rescon(sg,e,tp,mg))
	end
	sg:RemoveCard(c)
	return res
end
function cid.SelectUnselectGroup(g,e,tp,minc,maxc,rescon,chk,seltp,hintmsg,cancelcon,breakcon)
	local minc=minc and minc or 1
	local maxc=maxc and maxc or 99
	if chk==0 then return g:IsExists(cid.SelectUnselectLoop,1,nil,Group.CreateGroup(),g,e,tp,minc,maxc,rescon) end
	local hintmsg=hintmsg and hintmsg or 0
	local sg=Group.CreateGroup()
	while true do
		local cancel=sg:GetCount()>=minc and (not cancelcon or cancelcon(sg,e,tp,g))
		local mg=g:Filter(cid.SelectUnselectLoop,sg,sg,g,e,tp,minc,maxc,rescon)
		if (breakcon and breakcon(sg,e,tp,mg)) or mg:GetCount()<=0 or sg:GetCount()>=maxc then break end
		Duel.Hint(HINT_SELECTMSG,seltp,hintmsg)
		local tc=mg:SelectUnselect(sg,seltp,cancel,cancel)
		if not tc then break end
		if sg:IsContains(tc) then
			sg:RemoveCard(tc)
		else
			sg:AddCard(tc)
		end
	end
	return sg
end
--Check for free MMZ auxiliary, original from Percy
function cid.MZFilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 and c:IsControler(tp)
end
function cid.ChkfMMZ(sumcount)
	return	function(sg,e,tp,mg)
				return sg:FilterCount(cid.MZFilter,nil,tp)+Duel.GetLocationCount(tp,LOCATION_MZONE)>=sumcount
			end
end