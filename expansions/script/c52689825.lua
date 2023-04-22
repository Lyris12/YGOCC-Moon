--Engaged Mass
--Massa Ingaggiata
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_ENGAGED_MASS)
	--[[When this card is activated: You can reduce the Energy of all Engaged monsters to 0; place counters on this card equal to the amount of Energy that was reduced.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Once per turn: You can remove any number of counters from this card; increase the Energy of 1 Engaged monster by the numbers of counters you removed.
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetCost(aux.LabelCost)
	e2:SetTarget(s.entg)
	e2:SetOperation(s.enop)
	c:RegisterEffect(e2)
	--[[You can send this card to the GY; Special Summon from your hand or GY, 1 Drive Monster whose original Energy
	is lower than or equal to the number of counters that were on this card when this effect was activated. (This is treated as a Drive Summon.)]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(3)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:HOPT()
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.cannotpay(c,e,tp)
	return not c:IsCanChangeEnergy(0,tp,REASON_COST,e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local g=Duel.GetEngagedCards()
	if #g>0 and not g:IsExists(s.cannotpay,1,nil,e,tp) and Duel.IsCanAddCounter(tp,COUNTER_ENGAGED_MASS,Duel.GetTotalEnergy(),c) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		e:SetCategory(CATEGORY_COUNTER)
		local ct=0
		for tc in aux.Next(g) do
			local _,_,diff=tc:ChangeEnergy(0,tp,REASON_COST,true,c)
			ct=ct+math.abs(diff)
		end
		e:SetLabel(ct)
		if ct>0 then
			Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,COUNTER_ENGAGED_MASS)
		end
	else
		e:SetCategory(0)
		e:SetLabel(0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local ct=e:GetLabel()
	if ct>0 and c:IsCanAddCounter(COUNTER_ENGAGED_MASS,ct) then
		c:AddCounter(COUNTER_ENGAGED_MASS,ct)
	end
end

function s.enfilter(c,ct,e,tp,h)
	for i=1,ct do
		if h:IsCanUpdateEnergy(-i,tp,REASON_COST) and c:IsCanUpdateEnergy(i,tp,REASON_EFFECT,e) then
			return true
		end
	end
	return false
end
function s.entg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetCounter(COUNTER_ENGAGED_MASS)
	local g=Duel.GetEngagedCards()
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		if ct<=0 or #g<=0 then return false end
		for i=1,ct do
			if c:IsCanRemoveCounter(tp,COUNTER_ENGAGED_MASS,i,REASON_COST) and g:IsExists(Card.IsCanUpdateEnergy,1,nil,i,tp,REASON_EFFECT,e) then
				return true
			end
		end
		return false
	end
	e:SetLabel(0)
	if #g>0 then
		local n={}
		for i=1,ct do
			if c:IsCanRemoveCounter(tp,COUNTER_ENGAGED_MASS,i,REASON_COST) and g:IsExists(Card.IsCanUpdateEnergy,1,nil,i,tp,REASON_EFFECT,e) then
				table.insert(n,i)
			end
		end
		if #n==0 then return end
		Duel.HintMessage(tp,STRING_INPUT_ENERGY)
		local ann=Duel.AnnounceNumber(tp,table.unpack(n))
		c:RemoveCounter(tp,COUNTER_ENGAGED_MASS,ann,REASON_COST)
		local rem=ct-c:GetCounter(COUNTER_ENGAGED_MASS)
		Duel.SetTargetParam(rem)
	end
end
function s.enop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTargetParam()
	if not ct or ct<=0 then return end
	local g=Duel.GetEngagedCards()
	if #g>0 then
		Duel.HintMessage(tp,HINTMSG_ENERGY)
		local tg=g:FilterSelect(tp,Card.IsCanUpdateEnergy,1,1,nil,ct,tp,REASON_EFFECT,e)
		if #tg>0 then
			tg:GetFirst():UpdateEnergy(ct,tp,REASON_EFFECT,true,e:GetHandler(),e)
		end
	end
end

function s.spfilter(c,e,tp,ct,h)
	return c:IsMonster(TYPE_DRIVE) and c:GetOriginalEnergy()<=ct and Duel.GetMZoneCount(tp,h)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_DRIVE,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabelPair(1,0)
	local c=e:GetHandler()
	local ct=c:GetCounter(COUNTER_ENGAGED_MASS)
	if chk==0 then
		return e:IsActivated() and ct>0 and c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp,ct,c)
	end
	e:SetLabelPair(nil,ct)
	Duel.SendtoGrave(c,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local l1,l2=e:GetLabel()
	if chk==0 then
		local check=false
		if l1==1 then check=true end
		e:SetLabelPair(0)
		if not check then
			local c=e:GetHandler()
			local ct=c:GetCounter(COUNTER_ENGAGED_MASS)
			check = e:IsActivated() and ct>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp,ct)
		end
		return check
	end
	if l1~=1 then
		e:SetLabelPair(0,e:GetHandler():GetCounter(COUNTER_ENGAGED_MASS))
	else
		e:SetLabelPair(0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,1,nil,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local _,ct=e:GetLabel()
	if Duel.GetMZoneCount(tp)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp,ct)
	if #g>0 and Duel.SpecialSummon(g,SUMMON_TYPE_DRIVE,tp,tp,false,false,POS_FACEUP)>0 then
		g:GetFirst():CompleteProcedure()
	end
end