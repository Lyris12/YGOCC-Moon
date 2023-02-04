--Paracyclis Cyberbug, Beetle Atlas
--Automate ID
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
function s.spfilter(c)
	return c:IsSetCard(0x308) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end 
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil)
	return #rg>2 and rg:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil)
	local g=rg:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if ct<=1 then
		local drawct=2
		if ct==0 then
			drawct=3
		end
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,drawct)
	end
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=0
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSetGlitchy,tp,0,LOCATION_MZONE,nil,tp)
	if #g>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
		local tg=g:Select(1-tp,1,2,nil)
		ct=#tg
		if #tg>0 then
			Duel.HintSelection(tg)
			Duel.ChangePosition(tg,POS_FACEDOWN_DEFENSE)
			for tc in aux.Next(tg) do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:Desc(3)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
				e1:SetCondition(s.limcon)
				if Duel.GetTurnPlayer()==tp then
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
				else
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
				end
				e1:SetLabel(Duel.GetTurnCount(),tp)
				tc:RegisterEffect(e1)
			end
		end
	end
	if ct<=1 then
		local drawct=2
		if ct==0 then
			drawct=3
		end
		Duel.Draw(tp,drawct,REASON_EFFECT)
	end
end
function s.limcon(e)
	local ct,tp=e:GetLabel()
	return Duel.GetTurnCount()>ct and Duel.GetTurnPlayer()==1-tp
end
