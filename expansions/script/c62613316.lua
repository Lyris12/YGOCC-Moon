--Ploutonion, Portale Nottesfumo della Decadenza
--Script by XGlitchy30
function c62613316.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--def up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_XYZ))
	e1:SetValue(500)
	c:RegisterEffect(e1)	
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62613316,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,62613316)
	e2:SetLabel(100)
	e2:SetCondition(c62613316.bogcon)
	e2:SetTarget(c62613316.bogtg)
	e2:SetOperation(c62613316.bogop)
	c:RegisterEffect(e2)
	--mill
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(62613316,1))
	e3:SetLabel(101)
	c:RegisterEffect(e3)
	--spsummon synchro
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(62613316,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,60613316)
	e4:SetCost(c62613316.syncost)
	e4:SetTarget(c62613316.syntg)
	e4:SetOperation(c62613316.synop)
	c:RegisterEffect(e4)
	--replace field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(62613316,3))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,61613316)
	e5:SetCost(c62613316.actcost)
	e5:SetTarget(c62613316.acttg)
	e5:SetOperation(c62613316.actop)
	c:RegisterEffect(e5)
end
--filters
function c62613316.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6233) and c:IsType(TYPE_MONSTER)
end
function c62613316.bogfilter(c,val)
	if not val or (val~=100 and val~=101) then return false end
	return c:IsSetCard(0x6233) and ((val==100 and c:IsAbleToRemove()) or (val==101 and c:IsAbleToGrave()))
end
function c62613316.cfilter(c,ft,tp)
	if not c:IsType(TYPE_XYZ) then return false end
	return (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and c:IsFaceup() and c:IsSetCard(0x6233)
		and c:GetOverlayCount()>0 and c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
end
function c62613316.synfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x6233) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c62613316.fieldfilter(c,tp)
	return c:IsCode(62613315) and c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
--special summon
function c62613316.bogcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c62613316.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function c62613316.bogtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c62613316.bogfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	local category=0
	if e:GetLabel()==100 then
		category=CATEGORY_REMOVE 
	else
		category=CATEGORY_TOGRAVE
	end
	e:SetCategory(category)
	Duel.SetOperationInfo(0,category,nil,1,tp,LOCATION_DECK)
end
function c62613316.bogop(e,tp,eg,ep,ev,re,r,rp)
	local val=e:GetLabel()
	if not val or (val~=100 and val~=101) then return end
	local hint=0
	if e:GetLabel()==100 then
		hint=HINTMSG_REMOVE
	else
		hint=HINTMSG_TOGRAVE
	end
	Duel.Hint(HINT_SELECTMSG,tp,hint)
	local g=Duel.SelectMatchingCard(tp,c62613316.bogfilter,tp,LOCATION_DECK,0,1,1,nil,val)
	if g:GetCount()>0 then
		if val==100 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		else
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
--spsummon synchro
function c62613316.syncost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c62613316.cfilter,1,nil,ft,tp) end
	local g=Duel.SelectReleaseGroup(tp,c62613316.cfilter,1,1,nil,ft,tp)
	Duel.Release(g,REASON_COST)
end
function c62613316.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c62613316.synfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c62613316.synop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c62613316.synfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then 
		Duel.HintSelection(g)
		Duel.SpecialSummon(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
	end
end
--replace field
function c62613316.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c62613316.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c62613316.fieldfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function c62613316.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(62613316,3))
	local tc=Duel.SelectMatchingCard(tp,c62613316.fieldfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end