--Mano della Gloria
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	local e1=c:SentToGYFieldTrigger(nil,false,0,CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE,EFFECT_FLAG_DAMAGE_STEP,LOCATION_HAND+LOCATION_GRAVE,{1,0},aux.EventGroupCond(s.cf),false,aux.SSSelfTarget(true),s.op)
	
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