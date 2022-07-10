--Geneseed Cherry Tiger
local cid,id=GetID()
function cid.initial_effect(c)
c:EnableReviveLimit()
	   aux.AddOrigEvoluteType(c)
	 aux.AddEvoluteProc(c,nil,7,aux.AND(cid.filter1,cid.filter2),2,99)  
	--discard deck & draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(cid.drcost)
	e1:SetTarget(cid.drtg)
	e1:SetOperation(cid.drop)
	c:RegisterEffect(e1)
	  local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cid.spcon)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
	
end

function cid.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
	e:GetHandler():RemoveEC(tp,3,REASON_COST)
end
function cid.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return (chkc:IsOnField() or chkc:IsLocation(LOCATION_GRAVE)) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(800)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	
end
function cid.drop(e,tp,eg,ep,ev,re,r,rp)
	  local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT) ~=0 then
		  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)  
	end
end
function cid.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
function cid.filter2(c,ec,tp)
	return c:IsRace(RACE_PLANT) or c:IsRace(RACE_WYRM)
end


function cid.filter(c,tp)
	return  (c:IsPreviousLocation(LOCATION_HAND) or c:IsPreviousLocation(LOCATION_DECK)) and c:IsControler(tp)
end
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.filter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
   if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
