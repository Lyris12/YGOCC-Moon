--Mano della Gloria
--Scripted by: XGlitchy30

local s,id=GetID()

s.effect_text = [[
● You can only use the ① effect of "Gloryhand" once per turn.

① When a monster(s) your opponent controls is destroyed by battle or by the effect of a face-up monster you control and sent to the GY: You can Special Summon this card from GY (if it was there when the monster(s) was destroyed) or hand (even if not), and if you do, negate the effects of that destroyed monster(s) while it is in the GY.
② Once per turn, you can either (Quick Effect): Target 1 monster you control that destroyed a monster(s) your opponent controlled while on a Monster Zone this turn (either by battle or with its effect); equip this card to that target, OR: Unequip this card and Special Summon it.
③ The effects, the effect activations and activated effects of the equipped monster cannot be negated, also if the equipped monster would be destroyed by battle or card effect, destroy this card instead.
]]

function s.initial_effect(c)
	local e1=c:SentToGYFieldTrigger(false,0,CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE,EFFECT_FLAG_DAMAGE_STEP,LOCATION_HAND+LOCATION_GRAVE,{1,0},aux.EventGroupCond(s.cf),false,aux.SSSelfTarget(true),s.op)
	
	aux.AddUnionProcedure(c,s.unionf,false,false,false,true)
	
	SCRIPT_AS_EQUIP=true
	local e2=c:EffectsCannotBeNegated()
	local e3=c:EffectActivationsCannotBeNegated()
	local e4=c:ActivatedEffectsCannotBeNegated()
	SCRIPT_AS_EQUIP=false
	--
	aux.GlobalCheck(s,function()
		aux.EnableKillCounter(c,s.kf,s.vf,RESET_PHASE+PHASE_END)
	end
	)
end
function s.kf(c)
	return c:IsLocation(LOCATION_MZONE)
end
function s.vf(c,e,tp)
	return c:GetPreviousTypeOnField(TYPE_MONSTER) and c:IsPreviousControler(1-tp) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end

function s.filter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsLocation(LOCATION_MZONE)
end
function s.cf(c,_,tp)
	return c:GetPreviousTypeOnField()&TYPE_MONSTER>0 and c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsReason(REASON_DESTROY) and c:ByBattleOrEffect(s.filter,tp)(nil,tp)
end
function s.df(c)
	return c:IsMonster() and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_DESTROY)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local ss=aux.SSSelfOperation()(e,tp,eg,ep,ev,re,r,rp)
	if ss then
		local g=eg:Filter(s.df,nil)
		for tc in aux.Next(g) do
			Duel.NegateInGY(tc,e)
		end
	end
end

function s.unionf(c)
	return c:IsFaceup() and c:IsMonster() and c:HasFlagEffect(id)
end