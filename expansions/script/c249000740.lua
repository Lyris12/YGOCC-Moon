--Card Oracle
function c249000740.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1ED),3,true)
	aux.AddContactFusionProcedure(c,Card.IsReleasable,LOCATION_MZONE,0,Duel.Release,REASON_COST+REASON_MATERIAL)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c249000740.splimit)
	c:RegisterEffect(e1)
	--code
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(0x1ED)
	c:RegisterEffect(e2)
	--excavate deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(249000740,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c249000740.target)
	e3:SetOperation(c249000740.operation)
	c:RegisterEffect(e3)
	--special summon from gy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_PROC)
	e4:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(c249000740.spcon2)
	e4:SetOperation(c249000740.spop2)
	c:RegisterEffect(e4)
	if not c249000740.global_check then
		c249000740.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(c249000740.adjustop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c249000740.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function c249000740.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
function c249000740.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=math.min(5,Duel.GetFieldGroupCount(p,LOCATION_DECK,0))
	Duel.ConfirmDecktop(tp,ct)
	Duel.ShuffleDeck(tp)
	local g=Duel.GetDecktopGroup(tp,ct)
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffect(2490007402)==0 then
			tc:RegisterFlagEffect(2490007402,RESET_EVENT,tp+1,1)
		end
		tc=g:GetNext()
	end
end
function c249000740.adjustfilter(c)
	return c:IsSetCard(0x1ED) and c:GetFlagEffect(2490007401)==0 and c:IsFaceup()
end
function c249000740.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c249000740.adjustfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(2490007401,RESETS_STANDARD,1,1)
		local e1=Effect.CreateEffect(tc)
		e1:SetDescription(aux.Stringid(249000740,1))
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(c249000740.copycondition)
		e1:SetTarget(c249000740.copytarget)
		e1:SetOperation(c249000740.copyoperation)
		e1:SetReset(RESETS_STANDARD)
		e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
function c249000740.copycondition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSetCard(0x1ED)
end
function c249000740.effectcheck(c,tp,eg,ep,ev,re,r,rp,handler,check,chain)
	local t = {}
	local base_t = {}
	local t={}
	local desc_t = {}
	local p=1
	local key
	local value
	local key2
	local value2
	local se
	local te
	local con
	local co
	local tg
	if c:IsType(TYPE_MONSTER) then
		if global_card_effect_table[c] then		
			for key,value in pairs(global_card_effect_table[c]) do
				base_t[key]=value
			end
		end
		for key2,value2 in pairs(base_t) do
			if value2:IsHasType(EFFECT_TYPE_IGNITION) and value2:GetRange()&LOCATION_MZONE==LOCATION_MZONE and Duel.GetCurrentChain()<=chain and Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) then
				se=value2:Clone()
				te=Effect.CreateEffect(handler)
				con=se:GetCondition()
				co=se:GetCost()
				tg=se:GetTarget()
				op=se:GetOperation()
				if se:GetType() then te:SetType(se:GetType()) end
				if se:GetCode() then te:SetCode(se:GetCode()) end
				if se:GetCategory() then te:SetCategory(se:GetCategory()) end
				if se:GetProperty() then te:SetProperty(se:GetProperty()) end
				if con then te:SetCondition(con) end
				if co then te:SetCost(co) end
				if tg then te:SetTarget(tg) end
				if op then te:SetOperation(op) end
				handler:RegisterEffect(te)
				if (not con or con(te,tp,eg,ep,ev,re,r,rp)) and (not co or co(te,tp,eg,ep,ev,re,r,rp,0)) and (not tg or tg(te,tp,eg,ep,ev,re,r,rp,0))  then
					if check then
						se:Reset()
						te:Reset()
						return true
					end
					t[p]=te:Clone()
					desc_t[p]=se:GetDescription()
					p=p+1
				end
				se:Reset()
				te:Reset()
			elseif value2:IsHasType(EFFECT_TYPE_QUICK_O) and value2:GetCode()==EVENT_FREE_CHAIN then
				se=value2:Clone()
				te=Effect.CreateEffect(handler)
				con=se:GetCondition()
				co=se:GetCost()
				tg=se:GetTarget()
				op=se:GetOperation()
				te:SetType(EFFECT_TYPE_ACTIVATE)
				if se:GetCode() then te:SetCode(se:GetCode()) end
				if se:GetCategory() then te:SetCategory(se:GetCategory()) end
				if se:GetProperty() then te:SetProperty(se:GetProperty()) end
				if con then te:SetCondition(con) end
				if co then te:SetCost(co) end
				if tg then te:SetTarget(tg) end
				if op then te:SetOperation(op) end
				handler:RegisterEffect(te)
					if handler:CheckActivateEffect(false,false,false)~=nil then
						if check then
							se:Reset()
							te:Reset()
							return true
						end
						if se:GetType() then te:SetType(se:GetType()) end
						t[p]=te:Clone()
						desc_t[p]=se:GetDescription()
						p=p+1
				end
				te:Reset()
				se:Reset()
			end
		end
	else
		if c:IsType(TYPE_TRAP+TYPE_QUICKPLAY) or Duel.GetTurnPlayer()==tp and (Duel.GetCurrentChain()<=chain and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)) then
			te=c:CheckActivateEffect(false,false,false)
			if te~=nil and te:GetCode()==EVENT_FREE_CHAIN then
				if check then return true end
				return te
			end
		end
	end
	if #t>0 and check then return true end
	if #t>1 then
		local index=Duel.SelectOption(tp,table.unpack(desc_t)) + 1
		return t[index]
	elseif #t>0 then 
		return t[1]
	else
		return false
	end
end
function c249000740.copyfilter(c,tp,eg,ep,ev,re,r,rp,handler,chain)
	if c:IsCode(handler:GetCode()) then return false end
	if c:GetFlagEffect(2490007402)==0 then return false end
	if c:GetFlagEffect(2490007402)-1~=tp then return false end
	if c:IsType(TYPE_MONSTER) and not c:IsSummonableCard() then return false end
	if bit.band(c:GetType(),TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)~=0 or c:IsHasEffect(EFFECT_REMAIN_FIELD) then return false end
	return c249000740.effectcheck(c,tp,eg,ep,ev,re,r,rp,handler,true,chain)
end
function c249000740.copytarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c249000740.copyfilter,tp,0xFF,0xFF,1,nil,tp,eg,ep,ev,re,r,rp,c,0) and Duel.GetFlagEffect(tp,2490007403)<2 end
	Duel.RegisterFlagEffect(tp,2490007403,RESET_EVENT+RESET_PHASE+PHASE_END,1,1)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(58242947,1))
	local g=Duel.SelectMatchingCard(tp,c249000740.copyfilter,tp,0xFF,0xFF,1,1,nil,tp,eg,ep,ev,re,r,rp,c,1)
	local tc=g:GetFirst()
	Duel.Hint(HINT_CARD,0,tc:GetCode())
	tc:ResetFlagEffect(2490007402)
	local te=c249000740.effectcheck(tc,tp,eg,ep,ev,re,r,rp,c,false,1)
	c249000740[Duel.GetCurrentChain()]=te
	local co=te:GetCost()
	if co then co(e,tp,eg,ep,ev,re,r,rp,1) end
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
end
function c249000740.copyoperation(e,tp,eg,ep,ev,re,r,rp)
	local te=c249000740[Duel.GetCurrentChain()]
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function c249000740.spfilter3(c,att)
	return c:IsAttribute(att) and c:IsAbleToGraveAsCost()
end
function c249000740.spcon2(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c249000740.spfilter3,tp,LOCATION_HAND,0,1,nil,ATTRIBUTE_LIGHT)
		and Duel.IsExistingMatchingCard(c249000740.spfilter3,tp,LOCATION_HAND,0,1,nil,ATTRIBUTE_DARK)
end
function c249000740.spop2(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,c249000740.spfilter3,tp,LOCATION_HAND,0,1,1,nil,ATTRIBUTE_LIGHT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectMatchingCard(tp,c249000740.spfilter3,tp,LOCATION_HAND,0,1,1,nil,ATTRIBUTE_DARK)
	g1:Merge(g2)
	Duel.SendtoGrave(g1,REASON_COST)
end