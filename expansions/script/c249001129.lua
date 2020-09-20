--Mystical Cards of Borrowed Time
function c249001129.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,249001129+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c249001129.target)
	e1:SetOperation(c249001129.activate)
	c:RegisterEffect(e1)
end
function c249001129.gfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
function c249001129.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(c249001129.gfilter,tp,LOCATION_MZONE,0,nil)
		local ct=c249001129.count_unique_code(g)
		e:SetLabel(ct)
		return ct>0 and Duel.IsPlayerCanDraw(tp,ct)
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
function c249001129.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetMatchingGroup(c249001129.gfilter,tp,LOCATION_MZONE,0,nil)
	local ct=c249001129.count_unique_code(g)
	Duel.Draw(p,ct,REASON_EFFECT)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c249001129.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,1-tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,1-tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e3:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetOperation(c249001129.rmop)
	Duel.RegisterEffect(e4,p)
end
function c249001129.count_unique_code(g)
	local check={}
	local count=0
	local tc=g:GetFirst()
	while tc do
		for i,code in ipairs({tc:GetCode()}) do
			if not check[code] then
				check[code]=true
				count=count+1
			end
		end
		tc=g:GetNext()
	end
	return count
end
function c249001129.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end
function c249001129.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(e:GetOwnerPlayer(),LOCATION_HAND,0)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	Duel.Damage(tp,g:Filter(Card.IsLocation,nil,LOCATION_REMOVED):GetCount()*500,REASON_EFFECT)
end