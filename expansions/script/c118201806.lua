--created by Zolanark, coded by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.EnablePendulumAttribute(c,false)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_RITUAL),12,3,nil,nil,99)
	local p1=Effect.CreateEffect(c)
	p1:SetDescription(aux.Stringid(id,0))
	p1:SetCategory(CATEGORY_TOHAND)
	p1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	p1:SetCode(EVENT_PREDRAW)
	p1:SetRange(LOCATION_PZONE)
	p1:SetCondition(cid.thcon)
	p1:SetTarget(cid.thtg)
	p1:SetOperation(cid.thop)
	c:RegisterEffect(p1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(cid.splimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(cid.spcon)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cid.adjcon)
	e3:SetOperation(cid.adjop)
	c:RegisterEffect(e3)
end
cid.pendulum_level=12
function cid.thfilter(c)
	return c:IsSetCard(0x89f) and c:IsAbleToHand() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function cid.penfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x89f)
end
function cid.excfilter(c)
	return not c:IsType(TYPE_MONSTER) or not c:IsSetCard(0x89f)
end
function cid.posfilter(c,tp)
	return not c:IsPosition(POS_FACEUP_DEFENSE) and c:IsCanChangePosition()
		and Duel.IsExistingTarget(cid.tdfilter,tp,LOCATION_GRAVE,0,1,c)
end
function cid.tdfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER+TYPE_SPELL) and c:IsAbleToDeck()
end
function cid.checkshf(c,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(tp)
end
function cid.thcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetDrawCount(tp)>0
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	local dt=Duel.GetDrawCount(tp)
	if dt~=0 then
		_replace_count=0
		_replace_max=dt
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
		local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetLabel(cid)
		e2:SetLabelObject(e1)
		e2:SetReset(RESET_PHASE+PHASE_DRAW)
		e2:SetCondition(cid.checkcon1)
		e2:SetOperation(cid.checkop1)
		Duel.RegisterEffect(e2,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function cid.checkcon1(e,tp,eg,ep,ev,re,r,rp)
	local cid,orig_effect=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID,CHAININFO_TRIGGERING_EFFECT)
	return cid==e:GetLabel() and not e:GetOwner():IsRelateToEffect(orig_effect)
end
function cid.checkop1(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Reset()
	e:Reset()
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	_replace_count=_replace_count+1
	if _replace_count>_replace_max or not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
function cid.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ or bit.band(st,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.penfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.penfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
function cid.adjcon(e)
	return e:GetHandler():GetOverlayCount()>0 and not e:GetHandler():GetOverlayGroup():IsExists(cid.excfilter,1,nil)
end
function cid.adjop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(cid.poscost)
	e1:SetTarget(cid.postg)
	e1:SetOperation(cid.posop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3x:SetCode(EVENT_ADJUST)
	e3x:SetRange(LOCATION_MZONE)
	e3x:SetLabelObject(e1)
	e3x:SetCondition(cid.resetcon)
	e3x:SetOperation(cid.resetop)
	e3x:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3x)
end
function cid.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		local ct1,ct2,ct3=e:GetCountLimit()
		return (e:GetHandler():GetFlagEffect(id)<=0 or e:GetHandler():GetFlagEffectLabel(id)<ct1) and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) and Duel.IsExistingTarget(cid.posfilter,tp,0,LOCATION_MZONE,1,nil,tp) 
	end
	e:SetLabel(0)
	e:SetCategory(0)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	if e:GetHandler():GetFlagEffect(id)<=0 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,0)
	end
	e:GetHandler():SetFlagEffectLabel(id,e:GetHandler():GetFlagEffectLabel(id)+1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,cid.posfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectTarget(tp,aux.NecroValleyFilter(cid.tdfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	e:SetCategory(CATEGORY_POSITION+CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,#g1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,#g2,0,0)
end
function cid.posop(e,tp,eg,ep,ev,re,r,rp)
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_POSITION)
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	local tc1=g1:GetFirst()
	if tc1 and tc1:IsRelateToEffect(e) then
		Duel.ChangePosition(tc1,POS_FACEUP_DEFENSE)
		local hg=g2:Filter(Card.IsRelateToEffect,nil,e)
		Duel.SendtoDeck(hg,nil,2,REASON_EFFECT)
		for p=0,1 do
			if hg:IsExists(cid.checkshf,1,nil,p) then
				Duel.ShuffleDeck(p)
			end
		end
	end
end
function cid.resetcon(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0 and e:GetHandler():GetOverlayCount()<=0 or e:GetHandler():GetOverlayGroup():IsExists(cid.excfilter,1,nil)
end
function cid.resetop(e)
	if Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0 then
		Duel.ResetFlagEffect(e:GetHandlerPlayer(),id)
	end
	e:GetLabelObject():Reset()
	e:Reset()
end