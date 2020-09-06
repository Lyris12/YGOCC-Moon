--Earth Core of the Mecha Blades
local m=88880209
local cm=_G["c"..m]
function cm.initial_effect(c)
--xyz summon
	aux.AddXyzProcedure(c,cm.mfilter,4,2,cm.ovfilter,aux.Stringid(m,0),2,cm.xyzop)
	c:EnableReviveLimit()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetCondition(cm.discon)
	e2:SetOperation(cm.disop)
	c:RegisterEffect(e2)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(cm.efilter)
	c:RegisterEffect(e4)
end

function cm.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and e:GetHandler():GetOverlayCount()>2
end

function cm.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end
	e:GetHandler():RegisterFlagEffect(m,RESET_EVENT+RESETS_STANDARD,0,1)
	if not Duel.NegateEffect(ev) then return end
	local og=c:GetOverlayGroup()
	if og:GetCount()==0 then return end
	Duel.SendtoGrave(og,REASON_EFFECT)
	Duel.BreakEffect()
end

function cm.efilter(e,re,rp)
	if not re:IsActiveType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end

function cm.ovfilter(c)
	return c:IsFaceup()
		and ((c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,88880005))
		or (c:IsCode(88880006) and c:GetOverlayGroup():GetCount()>0))
end
function cm.xyzop(e,tp,chk,mc)
	if chk==0 then return mc:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	mc:RemoveOverlayCard(tp,1,1,REASON_COST)
end

function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,tc:GetPosition(),REASON_EFFECT) 
	end
end
function cm.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function cm.xyzfilter(c)
	return c:IsSetCard(0xffd) and c:IsFaceup()
end
function cm.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and cm.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.xyzfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(67865534,4))
	local g=Duel.SelectTarget(tp,cm.xyzfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,g,1,0,0)
end
function cm.xyzop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		Duel.Overlay(c,Group.FromCards(tc))
	end
end