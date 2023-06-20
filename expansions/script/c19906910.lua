--Paintress Dragon
  
local cid,id=GetID()
function cid.initial_effect(c)
c:EnableReviveLimit()
   aux.AddOrigConjointType(c)
	aux.EnableConjointAttribute(c,1)
	   aux.AddOrigEvoluteType(c)
	 aux.AddEvoluteProc(c,nil,8,cid.filter1,cid.filter1,2,99)  
	--damage conversion
   local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REVERSE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(cid.rev)
	c:RegisterEffect(e1)
--to hand
   local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(cid.descost)
	e2:SetTarget(cid.destg)
	e2:SetOperation(cid.desop)
	c:RegisterEffect(e2)
 --draw
   local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(cid.drcon)
	e3:SetTarget(cid.drtg)
	e3:SetOperation(cid.drop)
	c:RegisterEffect(e3)
end

function cid.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsType(TYPE_EFFECT)
end

function cid.rev(e,re,r,rp,rc)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
function cid.drcfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_PZONE) and c:IsPreviousControler(tp)
end
function cid.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.drcfilter,1,nil,tp)
end
function cid.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cid.drop(e,tp,eg,ep,ev,re,r,rp)
   local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function cid.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function cid.descost(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,4,REASON_COST) end
	e:GetHandler():RemoveEC(tp,4,REASON_COST)
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
   local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsFaceup() and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
   local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function cid.seqfilter(c,seq)
	return c:GetSequence()==seq
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
   local tc=Duel.GetFirstTarget()
local zone=1<<c:GetSequence()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
--Check an there is a target, stop effect if not
local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
if g:GetCount()==0 then return end
--Choose 1 opponent's monster, and gets its column
local tc=g:Select(tp,1,1,nil):GetFirst()
local zone=1<<tc:GetSequence()
--Destroy any card in the controller's S/T Zone in the same column
local desg=Duel.GetMatchingGroup(cid.seqfilter,tp,0,LOCATION_SZONE,nil,tc:GetSequence())
if #desg>0 then Duel.Destroy(desg,REASON_RULE) end
--Spellbind the chosen monster
if Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true,zone) then


local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetCode(EFFECT_CHANGE_TYPE)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
  e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
  tc:RegisterEffect(e1)
end
if e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_EVOLUTE) then
local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local des=dg:Select(tp,1,1,nil)
			Duel.HintSelection(des)
			Duel.BreakEffect()
			Duel.Destroy(des,REASON_EFFECT)
		end
end
end
end