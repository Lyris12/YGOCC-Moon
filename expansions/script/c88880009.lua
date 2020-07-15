--Mecha Blade Sky Angel
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
--xyz summon
	c:EnableReviveLimit()
	--alternative proc
	aux.AddXyzProcedure(c,cid.mfilter,4,2,cid.ovfilter,aux.Stringid(88880009,0),2,cid.xyzop)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetCondition(cid.sccon)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
end

--filters
function cid.tgfilter(c)
	return c:IsCode(88880006)
end
function cid.mfilter(c)
	return c:IsSetCard(0xffd)
end
function cid.ovfilter(c)
	return c:IsFaceup()
		and ((c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,88880005))
		or (c:IsCode(88880006) and c:GetOverlayGroup():GetCount()>0))
end
function cid.xyzop(e,tp,chk,mc)
	if chk==0 then return mc:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	mc:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function cid.fixfilter(c,e)
	return e:GetHandler():GetOverlayGroup():IsContains(c)
end
function cid.fixdisable(c,re)
	return c:IsCode(re:GetHandler():GetCode())
end
function cid.nfilter(c,cc)
	return c:IsCode(cc:GetCode())
end
--====================================================================================================================
function cid.sccon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function cid.mtfilter(c)
	return c:IsCanOverlay()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and cid.mtfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.mtfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local sg=Duel.SelectTarget(tp,cid.mtfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		Duel.Overlay(c,Group.FromCards(tc))
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(0,0xff)
		e1:SetTarget(cid.distg)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_PHASE+PHASE_END,1)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetCondition(cid.discon)
		e2:SetOperation(cid.disop)
		e2:SetLabelObject(tc)
		e2:SetReset(RESET_PHASE+PHASE_END,1)
		Duel.RegisterEffect(e2,tp)
	end
end
function cid.distg(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function cid.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(cid.fixdisable,1,nil,re) and re:GetHandler():GetFlagEffect(id)<=0
		and not re:GetHandler():IsControler(tp)
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	local rx=re:GetHandler()
	if not e:GetHandler():GetOverlayGroup():IsExists(cid.fixdisable,1,nil,re) or rx:GetFlagEffect(id)>0 or rx:IsControler(tp) then return end
	Duel.NegateEffect(ev)
end
function cid.fixfilter(c,e)
	return e:GetHandler():GetOverlayGroup():IsContains(c)
end
function cid.fixdisable(c,re)
	return c:IsCode(re:GetHandler():GetCode())
end
--====================================================================================================================
