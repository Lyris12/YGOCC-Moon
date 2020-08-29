--Cyberse Synchron Recoded
function c249000977.initial_effect(c)
	--gain effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c249000977.cost)
	e1:SetOperation(c249000977.operation)
	c:RegisterEffect(e1)
	--banish to give effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c249000977.condition2)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c249000977.operation2)
	c:RegisterEffect(e2)
end
function c249000977.costfilter(c)
	return (c:IsSetCard(0x1FE) or c:IsCode(70238111)) and not c:IsPublic()
end
function c249000977.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000977.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c249000977.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function c249000977.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	--synchro custom
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetTarget(c249000977.syntg)
	e1:SetValue(1)
	e1:SetOperation(c249000977.synop)
	e1:SetReset(RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function c249000977.synfilter1(c,syncard,tuner,f)
	return c:IsFaceup() and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
function c249000977.synfilter2(c,syncard,tuner,f)
	return c:IsRace(RACE_CYBERSE) and c:IsNotTuner(syncard) and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
function c249000977.syncheck(c,g,mg,tp,lv,syncard,minc,maxc)
	g:AddCard(c)
	local ct=g:GetCount()
	local res=c249000977.syngoal(g,tp,lv,syncard,minc,ct)
		or (ct<maxc and mg:IsExists(c249000977.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc))
	g:RemoveCard(c)
	return res
end
function c249000977.syngoal(g,tp,lv,syncard,minc,ct)
	return ct>=minc
		and g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,syncard)
		and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0
end
function c249000977.syntg(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	if lv<=c:GetLevel() then return false end
	local g=Group.FromCards(c)
	local mg=Duel.GetMatchingGroup(c249000977.synfilter1,syncard:GetControler(),LOCATION_MZONE,LOCATION_MZONE,c,syncard,c,f)
	local exg=Duel.GetMatchingGroup(c249000977.synfilter2,syncard:GetControler(),LOCATION_HAND,0,c,syncard,c,f)
	mg:Merge(exg)
	return mg:IsExists(c249000977.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc)
end
function c249000977.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local lv=syncard:GetLevel()
	local g=Group.FromCards(c)
	local mg=Duel.GetMatchingGroup(c249000977.synfilter1,syncard:GetControler(),LOCATION_MZONE,LOCATION_MZONE,c,syncard,c,f)
	local exg=Duel.GetMatchingGroup(c249000977.synfilter2,syncard:GetControler(),LOCATION_HAND,0,c,syncard,c,f)
	mg:Merge(exg)
	for i=1,maxc do
		local cg=mg:Filter(c249000977.syncheck,g,g,mg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if c249000977.syngoal(g,tp,lv,syncard,minc,i) then
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
function c249000977.confilter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x1FE) or c:IsCode(70238111))
end
function c249000977.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249000977.confilter,tp,LOCATION_GRAVE,0,1,e:GetHandler())
end
function c249000977.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	tg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):Filter(Card.IsType,nil,TYPE_TUNER)
	local tc=tg:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetTarget(c249000977.syntg)
		e1:SetValue(1)
		e1:SetOperation(c249000977.synop)
		e1:SetReset(RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=tg:GetNext()
	end
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetOperation(c249000977.hlvop2)
	Duel.RegisterEffect(e4,tp)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCESS)
	Duel.RegisterEffect(e5,tp)
	local e6=e4:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCESS)
	Duel.RegisterEffect(e6,tp)
end
function c249000977.hlvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hg=eg:Filter(Card.IsType,nil,TYPE_TUNER)
	local tc=hg:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetTarget(c249000977.syntg)
		e1:SetValue(1)
		e1:SetOperation(c249000977.synop)
		e1:SetReset(RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
end