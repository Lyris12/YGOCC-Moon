--Orbital Sky Lance: Panolethría
local id=88881000
local cid=_G["c"..id]

function cid.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PREDRAW)
	e0:SetRange(LOCATION_EXTRA+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_ONFIELD)
	e0:SetOperation(cid.start)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE+LOCATION_EXTRA)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(cid.tgcondition)
	e1:SetCost(cid.tgcost)
	e1:SetTarget(cid.tgtg)
	e1:SetOperation(cid.tgop)
	c:RegisterEffect(e1)	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE+LOCATION_EXTRA)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(cid.tgcondition)
	e2:SetCost(cid.tgcost)
	e2:SetTarget(cid.havoctarget)
	e2:SetOperation(cid.havocactivate)
	c:RegisterEffect(e2)
end

function cid.start(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	if c:GetFlagEffect(tp,id) == 0 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		local copyid = Duel.GetFlagEffect(tp,id)
		c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
		c:SetFlagEffectLabel(id,copyid)
		Debug.Message(c:GetFlagEffectLabel(id))
	end
end

function cid.tgcondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup()
end

function cid.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
	local sg=Duel.SelectMatchingCard(tp,Card.CheckRemoveOverlayCard,tp,LOCATION_MZONE,0,1,1,nil,tp,1,REASON_COST)
	sg:GetFirst():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function cid.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end

function cid.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	local uniqueId = c:GetFlagEffectLabel(id)
	local targetId = id + uniqueId
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(targetId,RESET_PHASE+PHASE_END,0,1)
	end
end

function cid.havocfilter(c,tid)
	return c:GetFlagEffect(tid)>0
end

function cid.havoctarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c = e:GetHandler()
	local uniqueId = c:GetFlagEffectLabel(id)
	local tid = id + uniqueId
	Debug.Message(tid)
	if chkc then return cid.havocfilter(chkc,tid) end
	if chk==0 then return Duel.IsExistingTarget(cid.havocfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tid) end
	local g=Duel.SelectTarget(tp,cid.havocfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tid)
end

function cid.havocactivate(e,tp,eg,ep,ev,re,r,rp)
	local fop=re:GetOperation()
	if fop then fop(e,tp,eg,ep,ev,re,r,rp) end
end
