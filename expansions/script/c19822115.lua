--created by Seth, coded by KitsuneTailsPrower aka somen00b
--The Shadow NOVA's Gift from the Dark Abyss
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91819979,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetDrawCount(tp)>0
end
function s.filter(c)
	return s:IsAbleToRemove() and c:IsLevelBelow(4) and c:IsSetCard(0xe1f)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_GRAVE,1,nil) end
	local dt=Duel.GetDrawCount(tp)
	if dt~=0 then
		aux.DrawReplaceCount=0
		aux.DrawReplaceMax=dt
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
	end
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	local ct=math.floor(tc.GetLevel() / 2)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct * 1000)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	aux.DrawReplaceCount=aux.DrawReplaceCount+1
	if aux.DrawReplaceCount<=aux.DrawReplaceMax and c:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		local ct=Duel.Draw(tp,math.floor(tc.GetLevel() / 2),REASON_EFFECT)
		if ct==0 then return end
		Duel.Damage(tp,ct * 1000,REASON_EFFECT)
	end
end
