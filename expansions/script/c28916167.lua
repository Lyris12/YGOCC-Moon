--This file was automatically coded by Kinny's Numeron Code~!
local ref=_G['c'..28916167]
local id=28916167
function ref.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Effect 0
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetRange(LOCATION_SZONE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1)
	e0:SetCost(ref.cost0)
	e0:SetTarget(ref.target0)
	e0:SetOperation(ref.operation0)
	c:RegisterEffect(e0)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_FLIP)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(ref.drawcon)
	e3:SetTarget(ref.drawtg)
	e3:SetOperation(ref.drawop)
	c:RegisterEffect(e3)
end
function ref.ShuffleVs(c)
	return c:IsSetCard(1856) and c:IsAbleToDeck() and c:IsType(TYPE_MONSTER)
end
function ref.SSVs(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(1856) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

--Effect 0
function ref.cost0(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.ShuffleVs,tp,LOCATION_HAND+LOCATION_GRAVE,0,3,nil) end
	local g0=Duel.SelectMatchingCard(tp,ref.ShuffleVs,tp,LOCATION_HAND+LOCATION_GRAVE,0,3,99,nil)
	if #g0>0 then
		if (g0:IsExists(Card.IsLocation,nil,1,LOCATION_HAND)) then
			Duel.ConfirmCards(1-tp,g0)
		end
		Duel.SendtoDeck(g0,tp,2,REASON_COST)
	end
end
function ref.target0(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanDraw(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,3,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,0)
end
function ref.operation0(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.Draw(tp,3,REASON_EFFECT)~=0 then
		local g2=Duel.GetOperatedGroup()
		Duel.ConfirmCards(tp,g2)
		local ct=3
		if ft<ct then ct=ft end
		local g4=g2:Filter(ref.SSVs,nil,e,tp):Select(tp,1,ct,nil)
		if Duel.SpecialSummon(g4,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local ssg=g4:Filter(Card.IsLocation,nil,LOCATION_MZONE)
			g2:Sub(ssg)
			local tc=ssg:GetFirst()
			while tc do
				Duel.RaiseSingleEvent(tc,EVENT_SUMMON_SUCCESS,e,REASON_EFFECT,tp,tc:GetControler(),ev)
				tc=ssg:GetNext()
			end
		end
		Duel.SendtoDeck(g2,tp,2,REASON_EFFECT)
	end
end
--DRAW
function ref.drawfilter(c,re)
	if not c:IsType(TYPE_MONSTER) or not c:IsSetCard(0x740) then return false end
	return re or (Duel.GetCurrentPhase()==PHASE_DAMAGE and Duel.GetAttackTarget() and Duel.GetAttackTarget()==c)
end
function ref.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(ref.drawfilter,1,nil,re)
end
function ref.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function ref.drawop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
	-----
	if not e:GetHandler():IsFaceup() then return end
	local fid=e:GetHandler():GetFieldID()
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE,1)
	e:GetHandler():SetFlagEffectLabel(id,fid)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(ref.splimit)
	e1:SetLabelObject(e:GetHandler())
	Duel.RegisterEffect(e1,p)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(1,0)
	e2:SetLabelObject(e1)
	e2:SetValue(ref.aclimit)
	Duel.RegisterEffect(e2,p)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetLabel(fid)
	e3:SetLabelObject(e2)
	e3:SetOperation(ref.reset)
	Duel.RegisterEffect(e3,tp)
end
function ref.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(1856)
end
function ref.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not re:GetHandler():IsSetCard(1856)
end
function ref.reset(e)
	local fid,card=e:GetLabel(),e:GetLabelObject():GetLabelObject():GetLabelObject()
	if not card then e:Reset() end
	if card and (card:GetFlagEffect(id)<=0 or card:GetFlagEffectLabel(id)~=fid) then
		e:GetLabelObject():GetLabelObject():Reset()
		e:GetLabelObject():Reset()
		e:Reset()
	end
end