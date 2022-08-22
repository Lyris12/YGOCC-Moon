--Strano Mantelleader
--Scripted by: XGlitchy30

local s,id=GetID()

s.effect_text = [[
● You can only use the ③ effect of "Spellcasters' Capetain" once per turn.

① Once per turn, you can either: Target 1 Spellcaster monster on the field; equip this card to that target, OR: Unequip this card and Special Summon it.
② A monster equipped with this card becomes DARK and gains 600 ATK/DEF, also if the equipped monster would be destroyed by battle or card effect, destroy this card instead.
③ If this card is sent from the field to the GY while equipped to a monster: You can target 1 monster your opponent controls; place 1 Casted Spell Counter on it, also, as long as that monster remains face-up on your opponent's field, when you activate the effect of a DARK Spellcaster monster, you can make that effect become the following one.
● Take control of 1 monster your opponent controls with a Casted Spell Counter(s) on it
]]

function s.initial_effect(c)
	--UNION PROCEDURE
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1068)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.UnionTarget)
	e1:SetOperation(Auxiliary.UnionOperation(s.union_filter))
	c:RegisterEffect(e1)
	--unequip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(Auxiliary.UnionSumTarget(nil))
	e2:SetOperation(Auxiliary.UnionSumOperation(nil))
	c:RegisterEffect(e2)
	--destroy sub
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e3:SetValue(Auxiliary.UnionReplace(nil))
	c:RegisterEffect(e3)
	--eqlimit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UNION_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(Auxiliary.UnionLimit(s.union_filter))
	c:RegisterEffect(e4)
	---------------------------------------
	--Stat boost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(600)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1x)
	--Change Attribute
	local e1y=e1:Clone()
	e1y:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1y:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e1y)
	--Place counter
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--Equip Check
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetCode(EVENT_LEAVE_FIELD_P)
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
end
s.counter_place_list={COUNTER_SPELL}

function s.regop(e)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec~=nil then
		c:RegisterFlagEffect(id+100,RESET_EVENT+RESETS_STANDARD_EXC_GRAVE,EFFECT_FLAG_IGNORE_IMMUNE,1)
	end
end

function s.union_filter(c)
	return c:IsMonster() and c:IsRace(RACE_SPELLCASTER)
end
function s.UnionTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and Auxiliary.UnionFilter(c,s.union_filter,nil) end
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(Auxiliary.UnionFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,s.union_filter,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,Auxiliary.UnionFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,s.union_filter,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	c:RegisterFlagEffect(id,RESET_EVENT+(RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE)+RESET_PHASE+PHASE_END,0,1)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:HasFlagEffect(id+100)
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsMonster() and c:IsCanAddCounter(0x1001,1)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local tc=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1001,1)
	if not tc:IsCanAddCounter(0x1001,1) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.tfilter(c)
	return c:IsCode(id) and c:IsAbleToHand()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- local fx
		-- if e:GetLabel()==1 then
			-- fx=Effect.CreateEffect(e:GetHandler())
			-- fx:SetType(EFFECT_TYPE_FIELD)
			-- fx:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			-- fx:SetCode(EFFECT_COUNTER_PERMIT+COUNTER_SPELL)
			-- fx:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			-- fx:SetTarget(function(ce,c) return c==tc end)
			-- fx:SetValue(LOCATION_MZONE)
			-- fx:SetReset(RESET_CHAIN)
			-- Duel.RegisterEffect(fx,tp)
		-- end
		if tc:AddCounter(0x1001,1) then
			tc:RegisterFlagEffect(id+100,RESET_EVENT+RESETS_STANDARD,0,1)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:Desc(1)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAINING)
			e1:SetLabel(tc:GetFieldID())
			e1:SetCondition(s.condition)
			e1:SetOperation(s.activate)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

function s.checkfilter(c,label)
	return c:HasFlagEffect(id+100) and c:GetFieldID()==label
end
function s.clf(c)
	return c:IsFaceup() and c:IsMonster() and c:GetCounter(0x1001)>0 and c:IsControlerCanBeChanged()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.checkfilter,tp,0,LOCATION_MZONE,1,nil,e:GetLabel()) then
		e:Reset()
		return false
	end
	local rc=re:GetHandler()
	return ep==tp and re:IsActiveType(TYPE_MONSTER) and rc:IsAttribute(ATTRIBUTE_DARK) and rc:IsRace(RACE_SPELLCASTER)
		and Duel.IsExistingMatchingCard(s.clf,tp,0,LOCATION_MZONE,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_CARD,0,id)
	local te=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
	Duel.ClearOperationInfo(ev)
	local categories=te:GetCategory()
	te:SetCategory(CATEGORY_CONTROL)
	Duel.SetOperationInfo(ev,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
	--
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
	--Restore original categories on Chain Link Resolution
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetLabel(ev,categories)
	e1:SetLabelObject(te)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local tg=Duel.SelectMatchingCard(tp,s.clf,tp,0,LOCATION_MZONE,1,1,nil)
	if #tg>0 then
		Duel.HintSelection(tg)
		Duel.GetControl(tg:GetFirst(),tp)
	end
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local ev0,_=e:GetLabel()
	return ev==ev0
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local _,categories=e:GetLabel()
	local te=e:GetLabelObject()
	if te and aux.GetValueType(te)=="Effect" and te.GetCategory then
		te:SetCategory(categories)
	end
	e:Reset()
end