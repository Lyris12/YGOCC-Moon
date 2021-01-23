--Legends and Myths, Arixael the Fallen Disciple
local s,id=GetID()
function s.initial_effect(c)
	--link summon
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(s.matfilter),2,2)
     --to hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCountLimit(1,id)
	e0:SetTarget(s.tdtg)
	e0:SetOperation(s.tdop)
	c:RegisterEffect(e0)
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+1)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end
function s.matfilter(c)
	return c:IsSetCard(0x190) or c:IsSetCard(0xFA0)
end
function s.tdfilter(c)
	return (c:IsSetCard(0xFA0) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()) and ((c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()) or (c:IsLocation(LOCATION_GRAVE)))
end
function s.tdfilter2(c)
	return c:IsSetCard(0xFA0) and c:IsAbleToRemove()
end
function s.desfilter(c)
	return c:IsDestructable() and c:IsFaceup()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) 
	and Duel.IsExistingMatchingCard(s.tdfilter2,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local g2=Duel.SelectMatchingCard(tp,s.tdfilter2,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 and #g2>0 and Duel.SendtoHand(g,nil,1,REASON_EFFECT)~=0 and Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		local g3=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #g3>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local tc=g3:GetFirst()
		local tc=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end

		
		
function s.cfilter(c,tp)
	return (c:IsPreviousSetCard(0x190) or c:IsPreviousSetCard(0xFA0)) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end

