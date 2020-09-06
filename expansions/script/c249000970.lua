--SKILL: Cyberse Extra Hand
--Script by Somen00b
local function getID()
    local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
    str=string.sub(str,1,string.len(str)-4)
    local cod=_G[str]
    local id=tonumber(string.sub(str,2))
    return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
    --ED Skill Properties
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetCondition(cid.skillcon)
    e1:SetValue(cid.efilter)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_SPSUMMON_CONDITION)
    e2:SetValue(0)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EFFECT_CANNOT_USE_AS_COST)
    e3:SetValue(1)
    c:RegisterEffect(e3)
    local e4=e1:Clone()
    e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e4:SetValue(1)
    c:RegisterEffect(e4)
    --Cyberse Extra Hand
    local SKILL=Effect.CreateEffect(c)
    SKILL:SetType(EFFECT_TYPE_FIELD)
    SKILL:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
    SKILL:SetRange(LOCATION_EXTRA)
    SKILL:SetCode(EFFECT_SPSUMMON_PROC_G)
    SKILL:SetCondition(cid.skillcon_skill)
    SKILL:SetOperation(cid.skillop)
    SKILL:SetValue(SUMMON_TYPE_SPECIAL+1)
    c:RegisterEffect(SKILL)
    --immune to necro valley
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_NECRO_VALLEY_IM)
	c:RegisterEffect(e5)
end
--filters
function cid.skillcon(e)
    return e:GetHandler():IsFaceup() and e:GetHandler():GetFlagEffect(99988871)>0
end
function cid.efilter(e,te)
    return te:GetOwner()~=e:GetOwner()
end
--Storm Access
function cid.skillcon_skill(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return cid.skillcon(e) and Duel.GetFlagEffect(tp,id)<=0
end
function cid.filter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToHand()
end
function cid.skillop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_CARD,1-tp,id)
   	if Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,1190) then
		local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Filter(Card.IsRace,nil,RACE_CYBERSE)
	local tc=hg:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
		e1:SetValue(aux.TRUE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
	hg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):Filter(Card.IsRace,nil,RACE_CYBERSE)
	local tc=hg:GetFirst()
	while tc do
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetTarget(cid.syntg)
		e2:SetValue(1)
		e2:SetOperation(cid.synop)
		tc:RegisterEffect(e2)
		tc=hg:GetNext()
	end
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetOperation(cid.hlvop)
	Duel.RegisterEffect(e3,tp)
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetOperation(cid.hlvop2)
	Duel.RegisterEffect(e4,tp)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCESS)
	Duel.RegisterEffect(e5,tp)
	local e6=e4:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCESS)
	Duel.RegisterEffect(e6,tp)
    Duel.RegisterFlagEffect(tp,id,0,0,1)
    return
end
function cid.hlvfilter(c,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsControler(tp)
end
function cid.hlvop(e,tp,eg,ep,ev,re,r,rp)
	local hg=eg:Filter(cid.hlvfilter,nil,tp)
	local tc=hg:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
		e1:SetValue(aux.TRUE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
end
function cid.hlvop2(e,tp,eg,ep,ev,re,r,rp)
	local hg=eg:Filter(cid.hlvfilter,nil,tp)
	local tc=hg:GetFirst()
	while tc do
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetTarget(cid.syntg)
		e2:SetValue(1)
		e2:SetOperation(cid.synop)
		tc:RegisterEffect(e2)
		tc=hg:GetNext()
	end
end
function cid.synfilter1(c,syncard,tuner,f)
	return c:IsFaceup() and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
function cid.synfilter2(c,syncard,tuner,f)
	return c:IsNotTuner(syncard) and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
function cid.syncheck(c,g,mg,tp,lv,syncard,minc,maxc)
	g:AddCard(c)
	local ct=g:GetCount()
	local res=cid.syngoal(g,tp,lv,syncard,minc,ct)
		or (ct<maxc and mg:IsExists(cid.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc))
	g:RemoveCard(c)
	return res
end
function cid.syngoal(g,tp,lv,syncard,minc,ct)
	return ct>=minc
		and g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,syncard)
		and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0
end
function cid.syntg(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	if c:IsNotTuner(syncard) or not c:IsRace(RACE_CYBERSE) then return false end
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	if lv<=c:GetLevel() then return false end
	local g=Group.FromCards(c)
	local mg=Duel.GetMatchingGroup(cid.synfilter1,syncard:GetControler(),LOCATION_MZONE,LOCATION_MZONE,c,syncard,c,f)
	local exg=Duel.GetMatchingGroup(cid.synfilter2,syncard:GetControler(),LOCATION_HAND,0,c,syncard,c,f)
	mg:Merge(exg)
	return mg:IsExists(cid.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc)
end
function cid.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local lv=syncard:GetLevel()
	local g=Group.FromCards(c)
	local mg=Duel.GetMatchingGroup(cid.synfilter1,syncard:GetControler(),LOCATION_MZONE,LOCATION_MZONE,c,syncard,c,f)
	local exg=Duel.GetMatchingGroup(cid.synfilter2,syncard:GetControler(),LOCATION_HAND,0,c,syncard,c,f)
	mg:Merge(exg)
	for i=1,maxc do
		local cg=mg:Filter(cid.syncheck,g,g,mg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if cid.syngoal(g,tp,lv,syncard,minc,i) then
			if not Duel.SelectYesNo(tp,210) then break end
			minct=0
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local sg=cg:Select(tp,minct,1,nil)
		if sg:GetCount()==0 then break end
		g:Merge(sg)
	end
	Duel.SetSynchroMaterial(g)
end