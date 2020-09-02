--created by ZEN, coded by ZEN & Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(cid.spcon)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(1131)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+500)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetCondition(function(e,tp,eg,ep,ev) return ep~=tp and Duel.IsChainDisablable(ev) end)
	e3:SetCost(cid.cost)
	e3:SetTarget(cid.distg)
	e3:SetOperation(cid.disop)
	c:RegisterEffect(e3)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+1000)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetCondition(cid.drcon)
	e2:SetTarget(cid.drtg)
	e2:SetOperation(cid.drop)
	c:RegisterEffect(e2)
end
function cid.cfilter(c)
	return c:IsSetCard(0xd7c) and c:IsFaceup()
end
function cid.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
end
function cid.splimit(e,c)
	return not c:IsSetCard(0xd7c)
end
function cid.dcfilter(c)
	return c:GetSequence()<5 and c:IsSetCard(0xd7c) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.dcfilter,tp,LOCATION_SZONE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(Duel.SelectMatchingCard(tp,cid.dcfilter,tp,LOCATION_SZONE,0,2,2,nil),REASON_COST)
end
function cid.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xd7c) and not c:IsForbidden()
end
function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cid.filter(chkc) end
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_DISABLED)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>-2
		and Duel.IsExistingTarget(cid.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,Duel.SelectTarget(tp,cid.filter,tp,LOCATION_GRAVE,0,1,1,nil),1,tp,LOCATION_GRAVE)
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not Duel.NegateEffect(ev) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not tc:IsRelateToEffect(e) then return end
	Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	tc:RegisterEffect(e1)
	Duel.RaiseEvent(tc,EVENT_CUSTOM+id+2,e,r,tp,tp,0)
end
function cid.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsSetCard(0xd7c)
end
function cid.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cid.pfilter(c)
	return c:IsSetCard(0xd7c) and not c:IsForbidden()
end
function cid.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	local g=Duel.GetMatchingGroup(cid.pfilter,tp,LOCATION_HAND,0,nil)
	if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	Duel.BreakEffect()
	Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	tc:RegisterEffect(e1)
	Duel.RaiseEvent(tc,EVENT_CUSTOM+id+2,e,r,tp,tp,0)
end
