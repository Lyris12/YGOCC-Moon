--Chronovert Dragon
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,8,s.sumcon,s.tlfilter)
	c:EnableReviveLimit()
	--If the activation or the effect of a card was negated this turn, you can also Time Leap Summon this card using a Level 6 or 5 Effect monster you control.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	e1:SetValue(SUMMON_TYPE_TIMELEAP)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
	--Once per turn when your opponent activates a card or effect in response to your card or effect activation: You can return this card you control to the Extra Deck, and if you do, negate that opponent's card, and if you do that, shuffle that card into the Deck.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.ngcon)
	e2:SetTarget(s.ngtg)
	e2:SetOperation(s.ngop)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_NEGATED)
		ge1:SetLabel(id)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_CHAIN_DISABLED)
		ge2:SetLabel(id)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.sumcon(e,c)
	local tp=c:GetControler()
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)~=0
end
function s.tlfilter(c,e,mg)
	local tp=c:GetControler()
	local ef=e:GetHandler():GetFuture()
	return c:IsType(TYPE_EFFECT) and c:IsLevelBelow(ef-1) and Duel.GetFlagEffect(e:GetHandlerPlayer(),id)<1
end
function s.hspfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsLevelBelow(7) and c:IsLevelAbove(5)
		and c:IsAbleToRemove(tp,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP) and c:IsCanBeTimeleapMaterial() --and Duel.GetLocationCountFromEx(tp,tp,c,TYPE_TIMELEAP) --had to remove this because this weird thing happened: if the extra monster zone is occupied, you cannot time leap summon using a level 6 or 5 even if other zones are empty
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return s.sumcon(e,c) and Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_MZONE,0,1,nil,tp) 
		and Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0 and Duel.GetFlagEffect(tp,EFFECT_EXTRA_TIMELEAP_MATERIAL)<=0 and c:IsAbleToRemove(tp,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP) and c:IsCanBeTimeleapMaterial()
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.hspfilter,tp,LOCATION_MZONE,0,0,1,true,nil,tp)
	if #g==0 then return false end
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
	aux.TimeleapHOPT(tp)
end
function s.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_MONSTER) and Duel.IsMainPhase())
end
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	if not (ep==1-tp and Duel.IsChainDisablable(ev)) or re:GetHandler():IsDisabled() then return false end
	local ch=Duel.GetCurrentChain(true)-1
	if ch>0 then
		local cplayer=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_CONTROLER)
		local ceff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT)
		if cplayer==tp then return true end
	end
end
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtra() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(tp) then
		if Duel.SendtoDeck(c,nil,0,REASON_EFFECT) then
			if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
				re:GetHandler():CancelToGrave()
				Duel.SendtoDeck(re:GetHandler(),REASON_EFFECT)
			end
		end
	end
end
