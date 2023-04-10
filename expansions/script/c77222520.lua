--Starlen the Magical Girl
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	--aux.AddTimeleapProc(c,2,s.sumcon,s.tlfilter)
	c:EnableReviveLimit()
	--You can also Time Leap Summon this card by using any Normal Summoned monster whose effects are negated.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	e1:SetValue(SUMMON_TYPE_TIMELEAP)
	c:RegisterEffect(e1)
	--If this card is Time Leap Summoned: you can draw cards until you have 2 cards in hand.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.drawcon)
	e2:SetTarget(s.drawtg)
	e2:SetOperation(s.drawop)
	c:RegisterEffect(e2)
	--If this card is sent to the GY by an opponent's card: You take no damage for the rest of this turn.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.nodamagecon)
	e3:SetOperation(s.nodamageop)
	c:RegisterEffect(e3)
end
function s.sumcon(e)
	local c=e:GetHandler()
	local tp=c:GetControler()
	local ct1=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD+LOCATION_HAND,0)
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)
	local diff=ct2-ct1
	return diff>1 and Duel.IsExistingMatchingCard(s.tlfilter,tp,LOCATION_MZONE,0,1,nil,tp) and Duel.GetFlagEffect(tp,EFFECT_EXTRA_TIMELEAP_MATERIAL)<=0
end
function s.tlfilter(c)
	return (not c:IsType(TYPE_TOKEN) and c:IsLevel(1) and c:IsFaceup()) or (c:IsDisabled() and c:IsType(TYPE_EFFECT) and c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_NORMAL))
		and c:IsAbleToRemove(tp,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP) and c:IsCanBeTimeleapMaterial() --and (Duel.GetLocationCountFromEx(tp,tp,c,TYPE_TIMELEAP)>0
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.tlfilter,tp,LOCATION_MZONE,0,0,1,true,nil)
	if #g==0 then return false end
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
	aux.TimeleapHOPT(tp)
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		return h<2 and Duel.IsPlayerCanDraw(tp,2-h)
	end
	local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2-h)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2-h)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local h=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	if h>=2 then return end
	Duel.Draw(p,2-h,REASON_EFFECT)
	local c=e:GetHandler()
	--your opponent takes no damage for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(e:GetHandler(),EFFECT_FLAG_OATH,1-tp,1,0,aux.Stringid(id,0),nil)
end
function s.nodamagecon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.nodamageop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(e:GetHandler(),EFFECT_FLAG_OATH,tp,1,0,aux.Stringid(id,0),nil)
end
