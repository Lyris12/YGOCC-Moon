--Chronologist Ruler, Genesis
--Keddy was here~
local cod,id=GetID()
function cod.initial_effect(c)
	--Link Summon
	aux.AddLinkProcedure(c,cod.matfilter,1)
	c:EnableReviveLimit()
	--Unaffected
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cod.immcon)
	e1:SetValue(cod.immval)
	c:RegisterEffect(e1)
	--10+ Turns (Cannot be target)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCondition(cod.cncon)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetCondition(cod.cncon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--20+ Turns (ATK/DEF)
	--Other "Chronologist" monsters you control gain 1000 ATK and 500 DEF for each monster your opponent controls.
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(Turn(20))
	e4:SetTarget(cod.etg)
	e4:SetValue(cod.val1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCategory(CATEGORY_DEFCHANGE)
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	e5:SetValue(cod.val2)
	c:RegisterEffect(e5)
	--30+ Turns (Destroy)
	-- Once per turn: You can target cards your opponent controls, up to the number of other "Chronologist" monsters you control; destroy them.
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(Turn(30))
	e6:SetTarget(cod.destg)
	e6:SetOperation(cod.desop)
	c:RegisterEffect(e6)
	--40+ Turns (Win)
	--At the end of the Damage Step, if this card in the Extra Monster Zone attacked your opponent directly, you win the Duel.
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_DAMAGE_STEP_END)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(Turn(40))
	e7:SetOperation(cod.wop)
	c:RegisterEffect(e7)
	--Check
	if not cod.global_check then
		cod.global_check=true
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e0:SetCode(EVENT_ADJUST)
		e0:SetOperation(cod.tcop)
		Duel.RegisterEffect(e0,0)
	end
end

--Materials
function cod.matfilter(c)
	return c:IsSetCard(0x593) and c:IsType(TYPE_LINK)
end

--Turn Count
cod.turn={1}
function cod.tcop(e,tp,eg,ep,ev,re,r,rp)
	local t=cod.turn
	local c=e:GetHandler()
	if Duel.GetTurnCount()~=table.unpack(t) then
		t[1]=Duel.GetTurnCount()
	else return false end
end

--Common Condition
function Turn(val)
	return function (e,tp,eg,ep,ev,re,r,rp)
				local t=cod.turn
				return table.unpack(t)>=val
			end
end

--Immune
function cod.immcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_LINK
end
function cod.immval(e,re,rp)
	local rc=re:GetHandler()
	return (((rc:GetType()==TYPE_SPELL or rc:GetType()==TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE))
		or (rc:IsType(TYPE_LINK) and re:IsActivated()))
end

--Cannot be target
function cod.cncon(e,tp,eg,ep,ev,re,r,rp)
	return Turn(10) and Duel.IsExistingMatchingCard(cod.dfilter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler())
end

--ATK/DEF Target
function cod.etg(e,c)
	return c:IsSetCard(0x593) and c~=e:GetHandler()
end

--ATK/DEF Values
function cod.val1(e,c)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*1000
end
function cod.val2(e,c)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*500
end

--Destroy
function cod.dfilter(c,ec)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x593) and c~=ec
end
function cod.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(cod.dfilter,tp,LOCATION_MZONE,0,nil,e:GetHandler())
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),tp,LOCATION_ONFIELD)
end
function cod.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	Duel.Destroy(g,REASON_EFFECT)
end

--Win
function cod.wop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_CHRONOLOGIST=0x60
	Duel.Win(tp,WIN_REASON_CHRONOLOGIST)
end